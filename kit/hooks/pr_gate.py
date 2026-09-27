#!/usr/bin/env python3
"""PR/push evidence gate for Claude Code (PreToolUse on Bash). Called by pr-gate.sh; stdlib only.

Blocks `gh pr create` and `git push` (exit 2, reason on stderr — Claude reads it) until the session can show
the reviews the platform guide requires for the branch being shipped:

  1. /simplify                         (Skill "simplify")
  2. /code-review                      (Skill "code-review")
  3. the repo's reviewer agent         (Agent backend-reviewer | frontend-reviewer — whichever is wired)
  4. a security pass                   (Skill "security-review" OR Agent security-reviewer; the agent is
                                        mandatory when files matching SENSITIVE changed)
  5. agent-work/<branch-slug>/<repo>/review.md under the work root, non-empty — the findings a human reads
     (task folder = branch slug; each repo it touches has its own subfolder). The work root is the workspace
     folder when this file is reached through a kit symlink (<workspace>/agent-kit/hooks), the repo itself when
     the kit was copied into <repo>/.claude/hooks, or $KIT_WORK_ROOT.
  6. `gh pr create` only: a body with "## Nasıl doğrulandı" and "## Self-review"

Evidence for 1–4 comes from this session's transcript (every Skill and Agent tool call is recorded there). A
later session may instead rely on the "## Gate" block that $commit-and-pr writes into review.md.

Escape hatch: KIT_GATE_SKIP=1 (with KIT_GATE_REASON="…") in the command or the environment passes the gate
and appends the skip to agent-work/<branch-slug>/<repo>/gate-skips.log, where a reviewer sees it.

`pr_gate.py --summary` prints what this session ran ("skills: … · agents: …"); the Stop hook uses it, so the
summary and the gate read the transcript the same way.
"""

from __future__ import annotations

import datetime
import json
import os
import pathlib
import re
import shlex
import subprocess
import sys

KIT = pathlib.Path(__file__).resolve().parent.parent  # <workspace>/agent-kit, or <repo>/.claude when copied
ROOT = pathlib.Path(os.environ.get("KIT_WORK_ROOT") or KIT.parent)
# Paths whose change makes the security-reviewer agent mandatory. Extend it for the workspace (a PII module, a
# legal/ folder, a payments package) — this is the one place.
SENSITIVE = re.compile(
    r"auth|session|permission|rbac|jwt|secret|password|credential|consent|migrations?/", re.IGNORECASE
)
# The PR body sections — the same rule as templates/pr-evidence.yml (CI) and $commit-and-pr.
PR_SECTIONS = ("## Nasıl doğrulandı", "## Self-review")
# Claude Code built-ins a user types that are not skills (kept out of the "ran" list).
CLI_COMMANDS = {"model", "clear", "compact", "config", "help", "login", "logout", "status", "cost",
                "resume", "exit", "memory", "permissions", "hooks", "agents", "mcp", "init", "doctor"}
HEREDOC = re.compile(r"<<-?\s*(['\"]?)(\w+)\1[^\n]*\n.*?\n\s*\2[ \t]*(?=\n|$)", re.DOTALL)
# Candidate PR bases when the command names none: the branch's nearest of these is what it will merge into.
# Workspace-specific integration branches go in KIT_PR_BASES (space-separated), checked first.
BASES = (*os.environ.get("KIT_PR_BASES", "").split(), "develop", "main", "master")
SHELL_WORDS = {"do", "then", "else", "time", "exec", "command", "env", "!", "{"}
# Promotion/deploy PRs carry no review of their own — keep this in step with templates/pr-evidence.yml's `if:`.
def is_promotion(base: str, head: str) -> bool:  # noqa: ARG001 — head kept for workspaces that promote by head
    return base == "production" or base.startswith("release/")


PR_REVIEWS = re.compile(r"(backend|frontend|security)-reviewer|/code-review|/security-review")


def git(repo: pathlib.Path, *args: str) -> str:
    out = subprocess.run(["git", "-C", str(repo), *args], capture_output=True, text=True, check=False)
    return out.stdout.strip() if out.returncode == 0 else ""


def segments(command: str) -> list[str]:
    """Split a shell command on ; && || | newline and ( ) — outside quotes only; heredoc bodies are dropped."""
    parts, cur, quote, i, text = [], [], "", 0, HEREDOC.sub("<<HEREDOC", command)
    while i < len(text):
        c = text[i]
        if c == "\\" and quote != "'":  # an escaped character (\" inside "…") never opens, closes or splits
            cur.append(text[i : i + 2])
            i += 2
            continue
        if quote:
            quote = "" if c == quote else quote
        elif c in "'\"":
            quote = c
        elif c in ";|&\n()":
            parts.append("".join(cur))
            cur = []
            i += 1
            continue
        cur.append(c)
        i += 1
    return [p for p in [*parts, "".join(cur)] if p.strip()]


def opt(argv: list[str], *flags: str) -> str | None:
    """The value of the first of `flags` in argv — `--flag value` or `--flag=value`; None when absent."""
    for i, a in enumerate(argv):
        name, eq, value = a.partition("=")
        if a in flags and i + 1 < len(argv):
            return argv[i + 1]
        if eq and name in flags:
            return value
    return None


def strip_options(args: list[str], with_value: tuple[str, ...]) -> list[str]:
    """Drop leading global options (`git -C x -c k=v --no-pager`, `gh -R o/r`) before the subcommand."""
    while args and args[0].startswith("-"):
        args = args[2:] if args[0] in with_value else args[1:]
    return args


def shipping_segment(command: str) -> tuple[str, list[str], dict[str, str]] | None:
    """Return ("pr"|"push", argv, leading VAR=value env) for the gh-pr-create / git-push part of a command."""
    for part in segments(command):
        try:
            argv = shlex.split(part)
        except ValueError:
            argv = part.split()
        while argv and argv[0] in SHELL_WORDS:  # `do git push`, `then gh pr create`, `env git push`
            argv = argv[1:]
        env: dict[str, str] = {}
        while argv and re.match(r"^[A-Za-z_]\w*=", argv[0]):  # leading VAR=value only, never a --body value
            key, _, value = argv.pop(0).partition("=")
            env[key] = value
        if argv[:1] == ["gh"] and strip_options(argv[1:], ("-R", "--repo"))[:2] == ["pr", "create"]:
            return "pr", argv, env
        if argv[:1] == ["git"] and strip_options(argv[1:], ("-C", "-c"))[:1] == ["push"]:
            return "push", argv, env
    return None


def base_for(repo: pathlib.Path, branch: str, argv: list[str]) -> str:
    """The branch the change merges into: --base, else the nearest candidate (fewest commits ahead of it)."""
    target = opt(argv, "--base", "-B")
    if target:
        return f"origin/{target}"
    ahead = []
    for name in BASES:
        if name != branch and git(repo, "rev-parse", "--verify", "-q", f"origin/{name}"):
            ahead.append((int(git(repo, "rev-list", "--count", f"origin/{name}..HEAD") or 0), f"origin/{name}"))
    return min(ahead)[1] if ahead else "origin/main"


def repo_for(command: str, argv: list[str], cwd: pathlib.Path) -> pathlib.Path:
    named = opt(argv, "-R", "--repo")  # gh -R owner/name from the workspace root → the sibling folder of that name
    if named and (cwd / named.rstrip("/").split("/")[-1] / ".git").exists():
        return (cwd / named.rstrip("/").split("/")[-1]).resolve()
    if opt(argv, "-C"):
        return (cwd / opt(argv, "-C")).resolve()
    m = re.search(r"(?:^|&&|;|\()\s*cd\s+([^&;)]+?)\s*(?:&&|;)", command)
    return (cwd / m.group(1).strip().strip("'\"")).resolve() if m else cwd


def transcript(payload: dict) -> pathlib.Path | None:
    given = payload.get("transcript_path")
    if given and pathlib.Path(given).is_file():
        return pathlib.Path(given)
    sid = payload.get("session_id")
    if sid:
        hits = sorted((pathlib.Path.home() / ".claude" / "projects").glob(f"*/{sid}.jsonl"))
        if hits:
            return hits[0]
    return None


def evidence(path: pathlib.Path | None) -> tuple[set[str], set[str]]:
    skills: set[str] = set()
    agents: set[str] = set()
    if not path:
        return skills, agents
    for line in path.open(encoding="utf-8", errors="replace"):
        # cheap pre-filter: only Skill / Agent calls and typed slash commands matter; tool results never do
        if '"Skill"' not in line and '"subagent_type"' not in line and "<command-name>" not in line:
            continue
        try:
            rec = json.loads(line)
        except json.JSONDecodeError:
            continue
        content = rec.get("message", {}).get("content")
        # a typed slash command is a user message that STARTS with the tag; the same text quoted anywhere else
        # (a tool result, a summary) is not a command
        if rec.get("type") == "user" and isinstance(content, str):
            m = re.match(r"\s*<command-name>/?([\w:-]+)</command-name>", content)
            if m and m.group(1).split(":")[-1] not in CLI_COMMANDS:
                skills.add(m.group(1).split(":")[-1])
        if not isinstance(content, list):
            continue
        for block in content:
            if not isinstance(block, dict) or block.get("type") != "tool_use":
                continue
            data = block.get("input") or {}
            if block.get("name") == "Skill" and data.get("skill"):
                skills.add(str(data["skill"]).split(":")[-1])
            if block.get("name") in ("Agent", "Task") and data.get("subagent_type"):
                agents.add(str(data["subagent_type"]).split(":")[-1])
    return skills, agents


def gate_block(text: str) -> str:
    m = re.search(r"^## Gate\s*$(.*?)(?=^## |\Z)", text, re.MULTILINE | re.DOTALL)
    return m.group(1) if m else ""


def pr_body(command: str, argv: list[str], cwd: pathlib.Path) -> str:
    """The PR body: --body-file / --body (also the --flag=value form); a heredoc body is read from the command."""
    path = opt(argv, "--body-file", "-F")
    if path:
        f = pathlib.Path(path) if pathlib.Path(path).is_absolute() else cwd / path
        return f.read_text(encoding="utf-8", errors="replace") if f.is_file() else ""
    body = opt(argv, "--body", "-b") or ""
    return body + "".join(m.group(0) for m in HEREDOC.finditer(command))


def reviewer_for(repo: pathlib.Path) -> str:
    """The profile reviewer link-repo.sh linked into the repo (the other profile's one is pruned there)."""
    linked = sorted(p.stem for p in (repo / ".claude" / "agents").glob("*-reviewer.md"))
    return next((n for n in linked if n != "security-reviewer"), "backend-reviewer")


def main() -> int:
    try:
        payload = json.load(sys.stdin)
    except json.JSONDecodeError:
        return 0
    if "--summary" in sys.argv[1:]:
        skills, agents = evidence(transcript(payload))
        if skills or agents:
            print(f"skills: {', '.join(sorted(skills)) or 'none'} · agents: {', '.join(sorted(agents)) or 'none'}")
        return 0
    command = (payload.get("tool_input") or {}).get("command", "")
    found = shipping_segment(command)
    if not found:
        return 0
    kind, argv, env = found
    # flags count only as real arguments of the shipping command, never as text inside a --body value
    if {"--dry-run", "--help", "-h"} & (set(argv) - {opt(argv, "--body", "-b")}):
        return 0
    cwd = pathlib.Path(payload.get("cwd") or os.getcwd())
    workdir = repo_for(command, argv, cwd)
    repo = pathlib.Path(git(workdir, "rev-parse", "--show-toplevel") or "")
    if not repo.parts or not (repo / ".git").exists():
        if "$" in " ".join(argv) or "$" in str(workdir):  # `for r in …; do git -C $r push` — cannot tell which repo
            print("pr-gate: push/PR target is a shell variable — run one repo per command so its reviews can be"
                  " checked.", file=sys.stderr)
            return 2
        if kind == "pr":  # gh works from anywhere with -R; the gate needs to know which repo's reviews to check
            print("pr-gate: cannot tell which repo this PR is for — run it inside the repo (cd <repo> && gh pr"
                  " create …) or with -R pointing at a repo folder of this workspace.", file=sys.stderr)
            return 2
        return 0
    branch = git(repo, "branch", "--show-current") or "detached"
    if kind == "pr" and is_promotion(opt(argv, "--base", "-B") or "", opt(argv, "--head", "-H") or branch):
        return 0
    slug = branch.replace("/", "-")
    work = ROOT / "agent-work" / slug / repo.name   # task folder, then one subfolder per repo it touches
    trail = f"agent-work/{slug}/{repo.name}"
    review = work / "review.md"

    if env.get("KIT_GATE_SKIP") == "1" or os.environ.get("KIT_GATE_SKIP") == "1":
        reason = env.get("KIT_GATE_REASON") or os.environ.get("KIT_GATE_REASON") or "(none)"
        reason = " ".join(reason.split())  # one log line per skip: no tab or newline from the reason
        work.mkdir(parents=True, exist_ok=True)
        with (work / "gate-skips.log").open("a", encoding="utf-8") as log:  # argv head only: no PR body text
            stamp = datetime.datetime.now().isoformat(timespec="seconds")
            log.write(f"{stamp}\t{repo.name}\t{kind}\t{reason}\t{' '.join(argv[:6])}\n")
        print(f"pr-gate: skipped for {repo.name}@{branch} — logged in {trail}/gate-skips.log",
              file=sys.stderr)
        return 0

    reviewer = reviewer_for(repo)
    review_text = review.read_text(encoding="utf-8", errors="replace") if review.is_file() else ""
    skills, agents = evidence(transcript(payload))
    carried = gate_block(review_text)

    def ran(name: str, pool: set[str]) -> bool:
        return name in pool or re.search(rf"\b{re.escape(name)}\b", carried) is not None

    changed = git(repo, "diff", "--name-only", f"{base_for(repo, branch, argv)}...HEAD").splitlines()
    sensitive = [f for f in changed if SENSITIVE.search(f)]

    missing = []
    if not ran("simplify", skills):
        missing.append("/simplify on the diff")
    if not ran("code-review", skills):
        missing.append("/code-review")
    if not ran(reviewer, agents):
        missing.append(f"Agent {reviewer} (cold review of the diff and the goal)")
    if sensitive and not ran("security-reviewer", agents):
        missing.append(f"Agent security-reviewer — security-relevant files changed: {', '.join(sensitive[:5])}")
    elif not (ran("security-review", skills) or ran("security-reviewer", agents)):
        missing.append("a security pass: /security-review or Agent security-reviewer")
    if not review_text.strip():
        missing.append(f"{trail}/review.md under {ROOT} — the reviewers' findings and what was done")
    if kind == "pr":
        body = pr_body(command, argv, workdir)
        for section in PR_SECTIONS:
            if not re.search(rf"^{re.escape(section)}", body, re.MULTILINE):
                missing.append(f"PR body section '{section}' ($commit-and-pr writes it)")
        if not PR_REVIEWS.search(body):
            missing.append("PR body naming the reviews that ran (*-reviewer, /code-review, /security-review)")

    if not missing:
        return 0
    print(
        f"pr-gate: {kind} of {repo.name}@{branch} blocked — the guide requires, before every push and PR:\n"
        + "\n".join(f"  - {m}" for m in missing)
        + "\nRun them, record the findings, then retry. Follow $commit-and-pr. Deliberate exception: prefix the"
        " command with KIT_GATE_SKIP=1 KIT_GATE_REASON=<why> (logged for the reviewer).",
        file=sys.stderr,
    )
    return 2


if __name__ == "__main__":
    sys.exit(main())
