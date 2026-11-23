#!/usr/bin/env python3
"""Check the read-only agents' shell allowlists against cases.tsv.

For each case: runs the Claude Code hook (in the mode the agent's file passes
it), and matches the command against the agent's OpenCode permission rules the
way OpenCode does (ordered rules, last match wins, `*` any characters, `?` one,
a pattern ending in " *" also matches the bare command). Also checks that each
agent file still wires the hook / starts its rules with a deny, and that the
hook blocks malformed input.

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
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
HOOK = ROOT / "dot_claude/hooks/executable_agent-shell-allowlist.sh"
CLAUDE = ROOT / "dot_claude/agents"
OPENCODE = ROOT / "dot_config/opencode/agents"
AGENTS = ["code-reviewer", "deep-reviewer", "performance-optimizer", "security-auditor"]
GROUPS = {
    "reviewers": ["code-reviewer", "deep-reviewer", "performance-optimizer"],
    "all": AGENTS,
}
ESCAPES = {"<NL>": "\n", "<CR>": "\r", "<VT>": "\v", "<FF>": "\f"}
BLOCKED = "BLOCKED by agent-shell-allowlist"
RULE = re.compile(
    r'- action: "?([\w*]+)"?\n\s+resource: "((?:[^"\\]|\\.)*)"\n\s+effect: (\w+)'
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
    return shell


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


def main():
    modes = {a: hook_mode(a) for a in AGENTS}
    rules = {a: opencode_rules(a) for a in AGENTS}

    count = 0
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
