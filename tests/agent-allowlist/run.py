#!/usr/bin/env python3
"""Check the agents' shell and edit allowlists against cases.tsv and EDIT_CASES.

For each case: runs the Claude Code hook (in the mode the agent's file passes
it), and matches the command against the agent's OpenCode permission rules the
way OpenCode does (ordered rules, last match wins, `*` any characters, `?` one,
a pattern ending in " *" also matches the bare command). Also checks that each
agent file still wires the hook / starts its rules with a deny, and that the
hook blocks malformed input. For edits: the read-only agents can't edit at
all, and the qa-tester's Edit|Write hook and OpenCode edit rules allow test
files only (EDIT_CASES), and the hook blocks paths outside the project,
traversal and symlinks.

Assumes no global OpenCode rule outranks an agent's own (agent rules are
appended last), and doesn't model OpenCode's per-subcommand splitting: cases
that rely on it are skipped on the OpenCode side ("-" in cases.tsv).

Run from anywhere: python3 tests/agent-allowlist/run.py
Needs /bin/bash and jq. CI runs it on Ubuntu (bash 5) and macOS (bash 3.2,
what the hook gets on the Mac). Exits 1 on any failure.
"""
import json
import re
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
HOOK = ROOT / "dot_claude/hooks/executable_agent-shell-allowlist.sh"
CLAUDE = ROOT / "dot_claude/agents"
OPENCODE = ROOT / "dot_config/opencode/agents"
EDIT_HOOK = ROOT / "dot_claude/hooks/executable_agent-edit-allowlist.sh"
AGENTS = ["code-reviewer", "deep-reviewer", "performance-optimizer", "security-auditor", "qa-tester"]
# Project-relative paths the qa-tester may (A) or may not (D) edit, checked
# against the Edit|Write hook and its OpenCode edit rules.
EDIT_CASES = [
    ("A", "front/src/cart/useCart.test.ts"),
    ("A", "front/src/cart/Cart.spec.tsx"),
    ("A", "server/internal/cart/service_test.go"),
    ("A", "front/src/cart/__tests__/helpers.ts"),
    ("A", "front/src/cart/__snapshots__/Cart.test.tsx.snap"),
    ("A", "server/internal/cart/testdata/cart.json"),
    ("A", "tests/cart/total.ts"),
    ("A", "front/e2e/checkout.ts"),
    ("A", "mobile/.maestro/login.yaml"),
    ("D", "front/src/cart/useCart.ts"),
    ("D", "server/internal/cart/service.go"),
    ("D", "front/package.json"),
    ("D", "front/vitest.config.ts"),
    ("D", ".github/workflows/checks.yml"),
    ("D", "latest/foo.ts"),
    ("D", "contest/foo.ts"),
    ("D", ".git/hooks/x.test.sh"),
    ("D", "sub/.git/tests/x"),
    ("D", "front/node_modules/x/index.test.js"),
    # Test-named, but loaded as config or code by some tool.
    ("D", ".github/workflows/ci.test.yml"),
    ("D", ".claude/agents/x.test.md"),
    ("D", ".claude/commands/test/x.md"),
    ("D", "front/.claude/skills/test/SKILL.md"),
    ("D", ".opencode/agents/x.test.md"),
    ("D", ".husky/test/pre-commit"),
    ("D", ".env.test.local"),
    ("D", "front/.env.test"),
    ("D", "dot_claude/agents/evil.test.md.tmpl"),
    ("D", "private_dot_config/test/x"),
    ("D", ".maestro/.claude/x.test.md"),
    ("D", "mobile/.maestro/sub/.github/x"),
    ("D", ".claude/.maestro/x.yaml"),
    ("D", "tests/agent-allowlist/cases.tsv"),
    ("D", "tests/agent-allowlist/run.py"),
]
# MCP servers (in opencode.json) whose tools the qa-tester gets in OpenCode.
QA_MCP = ["playwright", "chrome-devtools", "maestro"]
GROUPS = {
    "reviewers": ["code-reviewer", "deep-reviewer", "performance-optimizer"],
    "all": AGENTS,
}
ESCAPES = {"<NL>": "\n", "<CR>": "\r", "<VT>": "\v", "<FF>": "\f"}
BLOCKED = "BLOCKED by agent-shell-allowlist"
RULE = re.compile(
    r'- action: "?([\w*-]+)"?\n\s+resource: "((?:[^"\\]|\\.)*)"\n\s+effect: (\w+)'
)

failures = []


def fail(msg):
    failures.append(msg)


def frontmatter(path):
    parts = path.read_text().split("---\n")
    if len(parts) < 3:
        sys.exit(f"{path}: no frontmatter")
    return parts[1]


def hook_mode(agent):
    fm = frontmatter(CLAUDE / f"{agent}.md.tmpl")
    wiring = re.search(
        r'^hooks:\n  PreToolUse:\n    - matcher: "Bash"\n      hooks:\n'
        r'        - type: command\n          command: "~/\.claude/hooks/agent-shell-allowlist\.sh (\w+)"$',
        fm, re.M)
    if not wiring:
        fail(f"{agent}: Claude agent file doesn't wire agent-shell-allowlist.sh as a Bash PreToolUse hook")
        return None
    if not re.search(r'^tools: \[.*"Bash".*\]$', fm, re.M):
        fail(f"{agent}: Claude agent file doesn't list the Bash tool (the hook would be untested)")
    return wiring.group(1)


def opencode_rules(agent):
    fm = frontmatter(OPENCODE / f"{agent}.md.tmpl")
    found = RULE.findall(fm)
    if len(found) != fm.count("- action:"):
        fail(f"{agent}: parsed {len(found)} OpenCode rules of {fm.count('- action:')}: "
             "keep each rule as action / resource (double-quoted) / effect lines")
    rules = [(action, json.loads(f'"{res}"'), effect) for action, res, effect in found]
    shell = [(r, e) for a, r, e in rules if a in ("shell", "*")]
    if not shell or shell[0] != ("*", "deny"):
        fail(f"{agent}: OpenCode rules don't start by denying every shell command")
    edit = [(r, e) for a, r, e in rules if a in ("edit", "*")]
    if not edit or edit[0] != ("*", "deny"):
        fail(f"{agent}: OpenCode rules don't start by denying every edit")
    return shell, edit


def glob(pattern, command):
    rx = "".join(".*" if c == "*" else "." if c == "?" else re.escape(c) for c in pattern)
    if re.fullmatch(rx, command, re.S):
        return True
    return pattern.endswith(" *") and command == pattern[:-2]


def opencode(rules, command):
    effect = None
    for pattern, e in rules:
        if glob(pattern, command):
            effect = e
    return "A" if effect == "allow" else "D"


def hook(mode, stdin):
    """A, D (blocked on purpose: exit 2 with the BLOCKED message), or X."""
    r = subprocess.run(["/bin/bash", str(HOOK), mode], input=stdin, capture_output=True, text=True)
    if r.returncode == 0:
        return "A"
    if r.returncode == 2 and BLOCKED in r.stderr:
        return "D"
    return f"X (exit {r.returncode}, stderr {r.stderr.strip()[:80]!r})"


def edit_hook(stdin):
    r = subprocess.run(["/bin/bash", str(EDIT_HOOK)], input=stdin, capture_output=True, text=True)
    if r.returncode == 0:
        return "A"
    if r.returncode == 2 and "BLOCKED by agent-edit-allowlist" in r.stderr:
        return "D"
    return f"X (exit {r.returncode}, stderr {r.stderr.strip()[:80]!r})"


def edit_input(path, cwd):
    return json.dumps({"cwd": cwd, "tool_input": {"file_path": path}})


def check_edits(edit_rules):
    """The qa-tester's Edit|Write hook and OpenCode edit rules; returns the count."""
    fm = frontmatter(CLAUDE / "qa-tester.md.tmpl")
    if not re.search(r'^    - matcher: "Edit\|Write"\n      hooks:\n        - type: command\n'
                     r'          command: "~/\.claude/hooks/agent-edit-allowlist\.sh"$', fm, re.M):
        fail("qa-tester: Claude agent file doesn't wire agent-edit-allowlist.sh as an Edit|Write hook")
    for agent in AGENTS:
        if agent == "qa-tester":
            continue
        tools = re.search(r"^tools: \[(.*)\]$", frontmatter(CLAUDE / f"{agent}.md.tmpl"), re.M)
        if not tools or re.search(r'"(Edit|Write|NotebookEdit)"', tools.group(1)):
            fail(f"{agent}: Claude agent file must list its tools, without Edit/Write")
        if opencode(edit_rules[agent], "src/a.ts") != "D":
            fail(f"{agent}: OpenCode rules allow edits")

    count = 0
    with tempfile.TemporaryDirectory() as tmp:
        root = Path(tmp).resolve() / "proj"
        (root / "src").mkdir(parents=True)
        (root / ".git").mkdir()
        norepo = Path(tmp).resolve() / "norepo"
        norepo.mkdir()
        outside = Path(tmp).resolve() / "outside"
        outside.mkdir()
        (root / "src/link").symlink_to(outside)
        (root / "src/evil.test.ts").symlink_to(outside / "x")
        for want, rel in EDIT_CASES:
            count += 2
            got = edit_hook(edit_input(f"{root}/{rel}", str(root)))
            if got != want:
                fail(f"edit hook: want {want} got {got}: {rel}")
            got = opencode(edit_rules["qa-tester"], rel)
            if got != want:
                fail(f"opencode qa-tester edit: want {want} got {got}: {rel}")
        # Hook only: absolute paths outside the project, traversal, symlinks,
        # malformed input.
        for stdin in [
            edit_input(f"{outside}/a.test.ts", str(root)),
            edit_input(f"{root}/../outside/a.test.ts", str(root)),
            edit_input(f"{root}/src/./a.test.ts", str(root)),
            edit_input(f"{root}//a.test.ts", str(root)),
            edit_input(f"{root}proj2/a.test.ts", str(root)),
            edit_input(f"{root}/src/link/a.test.ts", str(root)),
            edit_input(f"{root}/src/evil.test.ts", str(root)),
            edit_input("src/a.test.ts", str(root)),
            edit_input(f"{root}/src/a.test.ts", "relative"),
            edit_input(f"{root}/.GIT/x.test.ts", str(root)),
            edit_input(f"{root}/.Claude/agents/x.test.md", str(root)),
            edit_input(f"{root}/src/a.ts\n/tests/x", str(root)),
            edit_input(f"{root}/tests/a.test.ts\n", str(root)),
            edit_input(f"{norepo}/tests/a.test.ts", str(norepo)),
            "", "not json", "{}", json.dumps({"tool_input": {"file_path": f"{root}/a.test.ts"}}),
        ]:
            count += 1
            got = edit_hook(stdin)
            if got != "D":
                fail(f"edit hook should block {stdin[:120]!r}, got {got}")
    return count


def check_mcp():
    """The qa-tester's OpenCode MCP rules allow each server's tools, by the
    action name OpenCode gives them (<server>_<tool>, other characters as _)."""
    fm = frontmatter(OPENCODE / "qa-tester.md.tmpl")
    rules = [(a, e) for a, _, e in RULE.findall(fm) if a not in ("shell", "edit", "read", "glob", "grep")]
    servers = json.loads((ROOT / "dot_config/opencode/opencode.json").read_text())["mcp"]
    for server in QA_MCP:
        if server not in servers:
            fail(f"qa-tester: MCP server {server!r} isn't in opencode.json")
        action = re.sub(r"[^a-zA-Z0-9_-]", "_", server) + "_some_tool"
        if opencode(rules, action) != "A":
            fail(f"qa-tester: OpenCode rules don't allow MCP action {action!r}")
    for other in ("github_create_issue", "exa_web_search_exa", "execute", "webfetch", "subagent"):
        if opencode(rules, other) != "D":
            fail(f"qa-tester: OpenCode rules allow {other!r}")
    return len(QA_MCP) + 5


def main():
    modes = {a: hook_mode(a) for a in AGENTS}
    parsed = {a: opencode_rules(a) for a in AGENTS}
    rules = {a: shell for a, (shell, _) in parsed.items()}
    count = check_edits({a: edit for a, (_, edit) in parsed.items()}) + check_mcp()

    text = (Path(__file__).parent / "cases.tsv").read_bytes().decode("utf-8")
    for n, line in enumerate(text.split("\n"), 1):
        if not line.strip() or line.startswith("#"):
            continue
        try:
            who, want_hook, want_oc, command = line.split("\t", 3)
        except ValueError:
            sys.exit(f"cases.tsv:{n}: expected 4 tab-separated columns")
        for token, char in ESCAPES.items():
            command = command.replace(token, char)
        if who not in GROUPS and who not in AGENTS:
            sys.exit(f"cases.tsv:{n}: unknown agent {who!r}")
        for agent in GROUPS.get(who, [who]):
            count += 1
            if modes[agent]:
                got = hook(modes[agent], json.dumps({"tool_input": {"command": command}}))
                if got != want_hook:
                    fail(f"cases.tsv:{n} hook {agent}: want {want_hook} got {got}: {command!r}")
            if want_oc != "-":
                got = opencode(rules[agent], command)
                if got != want_oc:
                    fail(f"cases.tsv:{n} opencode {agent}: want {want_oc} got {got}: {command!r}")

    for stdin in ["", "not json", "{}", '{"tool_input":{}}', '{"tool_input":{"command":42}}',
                  '{"tool_input":{"command":""}}']:
        count += 1
        got = hook("git", stdin)
        if got != "D":
            fail(f"hook should block malformed input {stdin!r}, got {got}")

    for f in failures:
        print("FAIL", f)
    print(f"{count} checks, {len(failures)} failures")
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
