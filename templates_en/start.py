#!/usr/bin/env python3
"""Install an agent template into a project, then print the bootstrap prompt.

    python3 start.py                          # interactive
    python3 start.py frontend-web ~/code/app  # direct
    python3 start.py --new python-service .   # empty repo: greenfield prompt
    python3 start.py --prompt-only            # just print the prompt

Copies the template's scaffolding into the target repo without overwriting
anything that is already there (--force overrides). Stdlib only, no install.
"""

import argparse
import shutil
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
TEMPLATES = sorted(p.name for p in HERE.iterdir() if p.is_dir() and (p / "AGENTS.md").exists())
MANIFESTS = ("package.json", "pyproject.toml", "setup.py", "go.mod", "Cargo.toml")
SCAFFOLD = {".ai", ".claude", ".github", ".vscode", ".impeccable", "docs", "tasks",
            "AGENTS.md", "CLAUDE.md", ".mcp.json", ".git"}


def copy_tree(src: Path, dst: Path, force: bool) -> tuple[list[str], list[str]]:
    written: list[str] = []
    skipped: list[str] = []
    for source in sorted(src.rglob("*")):
        if source.is_dir():
            continue
        target = dst / source.relative_to(src)
        if target.exists() and not force:
            skipped.append(str(target.relative_to(dst)))
            continue
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source, target)
        written.append(str(target.relative_to(dst)))
    return written, skipped


def looks_new(target: Path) -> bool:
    """No manifest and barely any code — the survey prompt would find nothing.

    Scaffolding does not count as code, so reinstalling into a repo does not
    make it look established.
    """
    if any((target / name).exists() for name in MANIFESTS):
        return False
    code = [p for p in target.rglob("*")
            if p.is_file() and p.relative_to(target).parts[0] not in SCAFFOLD]
    return len(code) < 5


def prompt_text(template: str, greenfield: bool = False) -> str:
    name = "bootstrap-prompt-greenfield.md" if greenfield else "bootstrap-prompt.md"
    text = (HERE / name).read_text(encoding="utf-8")
    return text.replace("{{TEMPLATE}}", template)


def ask(question: str, options: list[str]) -> str:
    for i, option in enumerate(options, 1):
        print(f"  {i}) {option}")
    while True:
        answer = input(f"{question} ").strip()
        if answer.isdigit() and 1 <= int(answer) <= len(options):
            return options[int(answer) - 1]
        if answer in options:
            return answer


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("template", nargs="?", choices=TEMPLATES, help="which template to install")
    parser.add_argument("target", nargs="?", help="path to the target repository")
    parser.add_argument("--new", action="store_true",
                        help="the repo is empty — print the greenfield prompt (decide, then scaffold) "
                             "instead of the one that surveys existing code")
    parser.add_argument("--force", action="store_true", help="overwrite files that already exist")
    parser.add_argument("--prompt-only", action="store_true", help="print the bootstrap prompt and exit")
    args = parser.parse_args()

    if args.prompt_only:
        print(prompt_text(args.template or "<template>", args.new))
        return 0

    template = args.template or ask("Template?", TEMPLATES)
    target = Path(args.target or input("Target repo path: ").strip()).expanduser().resolve()

    if not target.is_dir():
        print(f"error: {target} is not a directory", file=sys.stderr)
        return 1
    if not (target / ".git").exists():
        print(f"warning: {target} is not a git repository — hooks resolve their paths through git", file=sys.stderr)

    # Checked before copying: afterwards the template's own files fill the repo.
    if args.new and not looks_new(target):
        print("warning: --new given, but this repo already has code — without --new you get the "
              "prompt that surveys it, which is probably the one you want", file=sys.stderr)
    elif not args.new and looks_new(target):
        print("note: this repo looks empty — rerun with --new for the greenfield prompt, which decides "
              "the stack with you instead of surveying code that is not there yet", file=sys.stderr)

    written, skipped = copy_tree(HERE / template, target, args.force)

    print(f"\n{len(written)} file(s) written into {target}")
    if skipped:
        print(f"{len(skipped)} left untouched (already present — rerun with --force to overwrite):")
        for path in skipped[:20]:
            print(f"  · {path}")
        if len(skipped) > 20:
            print(f"  · … and {len(skipped) - 20} more")

    print("\n" + "=" * 72)
    print("NEXT: open the repo in your agent (Copilot agent mode or Claude Code)")
    print("and paste everything below this line.")
    print("=" * 72 + "\n")
    print(prompt_text(template, args.new))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
