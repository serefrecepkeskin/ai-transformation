#!/usr/bin/env python3
"""Generate <repo>/.github/agents/<name>.agent.md from <repo>/.claude/agents/<name>.md.

The Markdown files under .claude/agents are the canonical agent definitions (Claude Code reads them
natively); VS Code Copilot gets a generated twin. Only the `name:` and `description:` lines cross over —
`tools:`, `model:` and every other key are Claude-specific (Copilot has its own tool vocabulary and defaults
to all tools) and are dropped. Never edit the twins by hand: rerun this script (link-repo.sh calls it).
A generated twin whose source is gone (the agent was pruned for this profile) is removed; files in
.github/agents that this script did not generate (e.g. impeccable-*.agent.md) are left alone.

    python3 scripts/sync-copilot-agents.py <repo>            # write / prune
    python3 scripts/sync-copilot-agents.py <repo> --check    # report only; exit 1 when a twin is stale
"""

import pathlib
import re
import sys

MARK = "<!-- GENERATED from .claude/agents/{stem}.md by sync-copilot-agents.py — do not edit -->"


def split(md: str, name: str):
    m = re.match(r"^---\n(.*?)\n---\n(.*)$", md, re.S)
    if not m:
        raise SystemExit(f"{name}: expected YAML frontmatter")
    keep = [line for line in m.group(1).splitlines() if re.match(r"(name|description):", line)]
    if len(keep) != 2:
        raise SystemExit(f"{name}: frontmatter needs exactly one name: and one description: line")
    for line in keep:
        if line.split(":", 1)[1].strip()[:1] in (">", "|"):
            raise SystemExit(f"{name}: multi-line YAML values are not supported")
    return keep, m.group(2).lstrip("\n")


def main(repo: str, check: bool) -> int:
    root = pathlib.Path(repo).resolve()
    src = root / ".claude" / "agents"
    out = root / ".github" / "agents"
    if not src.is_dir():
        print(f"no {src}; nothing to do")
        return 0
    stale = 0
    wanted = set()
    for f in sorted(src.glob("*.md")):
        keep, body = split(f.read_text(encoding="utf-8"), f.name)
        text = "---\n" + "\n".join(keep) + "\n---\n" + MARK.format(stem=f.stem) + "\n\n" + body
        twin = out / f"{f.stem}.agent.md"
        wanted.add(twin.name)
        if twin.exists() and twin.read_text(encoding="utf-8") == text:
            print(f"ok    {twin.relative_to(root)}")
            continue
        stale += 1
        if check:
            print(f"stale {twin.relative_to(root)}")
            continue
        out.mkdir(parents=True, exist_ok=True)
        twin.write_text(text, encoding="utf-8")
        print(f"wrote {twin.relative_to(root)}")
    for twin in sorted(out.glob("*.agent.md")):
        if twin.name in wanted or "sync-copilot-agents.py" not in twin.read_text(encoding="utf-8"):
            continue
        stale += 1
        if check:
            print(f"stale {twin.relative_to(root)} (its agent is gone)")
        else:
            twin.unlink()
            print(f"prune {twin.relative_to(root)}")
    return 1 if check and stale else 0


if __name__ == "__main__":
    args = [a for a in sys.argv[1:] if a != "--check"]
    sys.exit(main(args[0] if args else ".", "--check" in sys.argv[1:]))
