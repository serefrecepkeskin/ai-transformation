#!/usr/bin/env python3
"""Install an agent template into a project, then print the bootstrap prompt.

    python3 start.py                          # interactive
    python3 start.py frontend-web ~/code/app  # direct
    python3 start.py --new python-service .   # empty repo: greenfield prompt
    python3 start.py --prompt-only            # just print the prompt

Copies the template's scaffolding into the target repo without overwriting
anything that is already there (--force overrides), then reports what the
commit-time lint gate still needs. Stdlib only, no install.
"""

import argparse
import shutil
import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
TEMPLATES = sorted(p.name for p in HERE.iterdir() if p.is_dir() and (p / "AGENTS.md").exists())
MANIFESTS = ("package.json", "pyproject.toml", "setup.py", "go.mod", "Cargo.toml")
LINT_FILES = (".pre-commit-config.yaml", "requirements-dev.txt",
              ".husky/pre-commit", ".lintstagedrc.json", "eslint.config.js")
SCAFFOLD = {".ai", ".claude", ".github", ".vscode", ".impeccable", "docs", "tasks",
            "AGENTS.md", "CLAUDE.md", ".mcp.json", ".git", ".husky",
            ".lintstagedrc.json", ".pre-commit-config.yaml", "requirements-dev.txt",
            "eslint.config.js"}


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


def read_text(path: Path) -> str:
    """File contents, or "" — a config we cannot read is a config we cannot judge."""
    try:
        return path.read_text(encoding="utf-8", errors="ignore")
    except OSError:
        return ""


def report_lint_readiness(target: Path, written: set[str], skipped: set[str]) -> None:
    """Say what the commit-time gate still needs. Reads only; installs nothing.

    The template ships the config files. Whether the toolchain is installed and
    whether the git hook is wired are the two questions a script can answer;
    whether the config matches this repo's real stack is the agent's job, via
    the bootstrap prompt.
    """
    lines = []
    for name in LINT_FILES:
        if name in written:
            lines.append(f"  ok   {name:<24} written by this install")
        elif name in skipped:
            lines.append(f"  ok   {name:<24} already present, left untouched")
    if not lines:
        return

    # Each template brings its own ecosystem's runner: pre-commit (pip) for
    # python, husky + lint-staged (npm) for frontend. Check the one that landed.
    package = read_text(target / "package.json")

    if (target / ".pre-commit-config.yaml").exists():
        if shutil.which("pre-commit"):
            lines.append(f"  ok   {'pre-commit':<24} on PATH")
        else:
            lines.append(f"  todo {'pre-commit':<24} not installed  ->  pip install pre-commit")
        if (target / ".git" / "hooks" / "pre-commit").exists():
            lines.append(f"  ok   {'.git/hooks/pre-commit':<24} wired")
        else:
            lines.append(f"  todo {'.git/hooks/pre-commit':<24} not wired      ->  pre-commit install")

    if (target / ".husky" / "pre-commit").exists():
        if (target / "node_modules" / ".bin" / "lint-staged").exists():
            lines.append(f"  ok   {'husky + lint-staged':<24} installed")
        else:
            lines.append(f"  todo {'husky + lint-staged':<24} missing        ->  npm i -D husky lint-staged")
        if '"prepare"' in package and "husky" in package:
            lines.append(f"  ok   {'package.json prepare':<24} wires the hook on npm install")
        else:
            lines.append(f'  todo {"package.json prepare":<24} not set        ->  npm pkg set scripts.prepare=husky')
        if (target / ".husky" / "_").is_dir():
            lines.append(f"  ok   {'core.hooksPath':<24} pointed at .husky/")
        else:
            lines.append(f"  todo {'core.hooksPath':<24} not pointed    ->  npm install (runs prepare)")

    pyproject = read_text(target / "pyproject.toml")
    if pyproject and "[tool.ruff]" not in pyproject:
        lines.append("  ask  pyproject.toml has no [tool.ruff] section — the bootstrap prompt adds it")

    if package:
        if '"lint"' not in package:
            lines.append('  ask  package.json has no "lint" script — the bootstrap prompt adds it')
        if "lint-staged" in package and not (target / ".lintstagedrc.json").exists():
            lines.append("  ask  lint-staged already configured in package.json — the bootstrap prompt reconciles the two")

    print("\nlint readiness")
    print("\n".join(lines))


def offer_precommit_install(target: Path) -> None:
    """Interactive only, explicit yes only. `pre-commit install` writes into
    .git/hooks/, and a setup script has no business doing that unasked.

    The husky side needs no equivalent: `npm install` wires its hook through the
    prepare script, so there is nothing extra to offer.
    """
    if not (target / ".pre-commit-config.yaml").exists():
        return
    if not shutil.which("pre-commit"):
        return
    if (target / ".git" / "hooks" / "pre-commit").exists():
        return
    if input("\nrun `pre-commit install` now? [y/N] ").strip().lower() != "y":
        return
    subprocess.run(["pre-commit", "install"], cwd=target, check=False)


def prompt_text(template: str, greenfield: bool = False) -> str:
    name = "bootstrap-prompt-greenfield.md" if greenfield else "bootstrap-prompt.md"
    text = (HERE / name).read_text(encoding="utf-8")
    return text.replace("{{TEMPLATE}}", template)


def ask_path(question: str) -> str:
    """Keep asking until something is typed.

    An empty answer would resolve to the current directory, which is almost
    never the repo that was meant — and installing a template into the wrong
    repo is tedious to undo.
    """
    while True:
        answer = input(question).strip()
        if answer:
            return answer
        print("  a path is required — type '.' for the current directory", file=sys.stderr)


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

    interactive = not (args.template and args.target)
    template = args.template or ask("Template?", TEMPLATES)
    target = Path(args.target or ask_path("Target repo path: ")).expanduser().resolve()

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

    report_lint_readiness(target, set(written), set(skipped))
    if interactive:
        offer_precommit_install(target)

    print("\n" + "=" * 72)
    print("NEXT: open the repo in your agent (Copilot agent mode or Claude Code)")
    print("and paste everything below this line.")
    print("=" * 72 + "\n")
    print(prompt_text(template, args.new))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
