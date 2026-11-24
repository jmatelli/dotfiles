#!/bin/bash
#
# PreToolUse hook (Edit|Write) for the qa-tester subagent, set in its
# frontmatter: it may only create or edit test files inside the project.
# The same list is in dot_config/opencode/agents/qa-tester.md.tmpl as
# OpenCode edit rules; tests/agent-allowlist/run.py checks both.
#
# Allowed: *.test.*, *.spec.*, *_test.go, and files under __tests__/,
# __snapshots__/, testdata/, test/, tests/, e2e/, .maestro/, below the
# hook's cwd (a git repo). Never under a dot directory (but .maestro) or a
# chezmoi dot_ source, node_modules/ or tests/agent-allowlist/, never through
# a symlink, never with . or .. in the path. Fails closed: any error blocks.

set -u
export LC_ALL=C
# shellcheck disable=SC2154  # rc is set inside the trap string
trap 'rc=$?; [ "$rc" = 0 ] || exit 2' EXIT

block() {
  echo "BLOCKED by agent-edit-allowlist: $1. You may only create or edit test files (*.test.*, *.spec.*, *_test.go, or under __tests__/, __snapshots__/, testdata/, test/, tests/, e2e/, .maestro/) inside the project; report other changes to the caller instead." >&2
  exit 2
}

command -v jq >/dev/null || block "jq not found"
INPUT=$(cat)
# jq rejects control characters: $(…) would strip a trailing newline, so the
# checks below would see another path than the one written.
NOCNTRL='strings | select(test("[[:cntrl:]]") | not)'
FILE=$(printf '%s' "$INPUT" | jq -er ".tool_input.file_path | $NOCNTRL") || block "unreadable hook input, or control characters in the path"
ROOT=$(printf '%s' "$INPUT" | jq -er ".cwd | $NOCNTRL") || block "no cwd in hook input, or control characters in it"
ROOT=${ROOT%/}
[[ "$FILE" == /* ]] || block "the path must be absolute"
[[ "$ROOT" == /?* ]] || block "the project directory must be absolute"
# A project, not ~ or / (where test/ and tests/ would match far too much).
[ -e "$ROOT/.git" ] || block "$ROOT is not a git repository"
case "$FILE/" in
  */./* | */../* | *//*) block "no . or .. or empty components in the path" ;;
esac
REL=${FILE#"$ROOT"/}
[ "$REL" != "$FILE" ] && [ -n "$REL" ] || block "$FILE is outside the project ($ROOT)"

# No symlinks on the way: a test-named link could point anywhere. And no
# component that tools load as config or code whatever its name: dot
# directories and files (.git, .github/workflows, .claude, .opencode, .husky,
# .env.test…) except .maestro, chezmoi sources (dot_claude/agents/x.test.md
# would be deployed as an agent), node_modules.
shopt -s nocasematch  # macOS file systems ignore case: .GIT is .git
DIR=$ROOT
IFS=/ read -r -a PARTS <<<"$REL"
for part in "${PARTS[@]}"; do
  DIR=$DIR/$part
  [ -L "$DIR" ] && block "$DIR is a symlink"
  case "$part" in
    .maestro) ;;
    .* | dot_* | *_dot_* | node_modules) block "$REL is under $part, which tools load as config or code" ;;
  esac
done
shopt -u nocasematch
# Its own checks.
case "$REL" in
  tests/agent-allowlist/*) block "$REL is the agents' allowlist tests" ;;
esac

case "$REL" in
  *.test.* | *.spec.* | *_test.go | *__tests__/* | *__snapshots__/* \
    | testdata/* | */testdata/* | test/* | */test/* | tests/* | */tests/* \
    | e2e/* | */e2e/* | .maestro/* | */.maestro/*)
    exit 0 ;;
esac
block "$REL is not a test file"
