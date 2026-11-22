#!/bin/bash
#
# PreToolUse hook for the read-only subagents (code-reviewer, deep-reviewer,
# performance-optimizer, security-auditor), set in each agent's frontmatter
# so it runs only inside that agent. Claude Code's agent files can't limit
# Bash to some commands; this does what OpenCode's permission rules do for the
# same agents (dot_config/opencode/agents/).
#
# Usage: agent-shell-allowlist.sh <git|security>
#   git       git diff / log / show only
#   security  those, plus the scanners in their fixed forms (see SCANNERS)
#
# The command runs in zsh, which expands far more than it looks: quotes,
# $'…', braces, globs with code in them (*(e:…:)), =(…) substitution, tabs.
# So the command may only contain plain characters (SAFE): then splitting
# it on spaces gives exactly the words the shell will run, and the checks
# below see what actually runs. Fails closed: any error blocks.
# No ^: with extended_glob on, ^x would expand to file names (a file named
# --output=… would come back as a flag). Keep extended_glob, and global
# aliases (alias -g), out of the interactive config for the same reason.

set -u
export LC_ALL=C  # [A-Za-z] is a byte range in every locale
MODE=${1:-git}
# shellcheck disable=SC2154  # rc is set inside the trap string
trap 'rc=$?; [ "$rc" = 0 ] || exit 2' EXIT

block() {
  echo "BLOCKED by agent-shell-allowlist ($MODE): $1. Run one allowed command at a time, exactly in the documented form, with plain arguments; use the Read, Grep and Glob tools for files." >&2
  exit 2
}

command -v jq >/dev/null || block "jq not found"
INPUT=$(cat)
COMMAND=$(printf '%s' "$INPUT" | jq -er '.tool_input.command | strings') || block "unreadable hook input"
[ -n "$COMMAND" ] || block "empty command"

# Letters, digits, single spaces and . _ / : = @ + ~ , % -
# Nothing that quotes, expands, globs, chains, redirects or substitutes.
SAFE='^[A-Za-z0-9._/:=@+~,%-]+( [A-Za-z0-9._/:=@+~,%-]+)*$'
[[ "$COMMAND" =~ $SAFE ]] || block "only letters, digits, single spaces and . _ / : = @ + ~ , % - are allowed (no quotes or ^: use HEAD~1, --format=%h%x20%s)"

read -r -a WORDS <<<"$COMMAND"
for w in "${WORDS[@]}"; do
  case "$w" in
    =*) block "a word starting with = expands in zsh" ;;
  esac
done

# git diff / log / show, optionally with -C <dir>. Flags are allowed, except
# those that write files, run external diff or textconv programs, or read
# an order file.
if [[ "$COMMAND" =~ ^git(\ -C\ [^\ ]+)?\ (diff|log|show)(\ |$) ]]; then
  for w in "${WORDS[@]}"; do
    case "$w" in
      --output | --output=* | --ext-diff | --textconv | -O*)
        block "git flag $w writes a file or runs a program" ;;
    esac
  done
  exit 0
fi

[ "$MODE" = security ] || block "'$COMMAND' is not on the allowlist (git diff/log/show only)"

# Scanners: the fixed prefix, then only plain paths (nothing starting with -),
# so no flag can write a report, load config, change the output or reach the
# network. trivy gets --config /dev/null so a trivy.yaml in the audited repo
# can't do any of that either.
SCANNERS=(
  'gitleaks dir --redact --no-banner'
  'gitleaks git --redact --no-banner'
  'trivy fs --config /dev/null --scanners vuln,misconfig,secret --quiet'
  'semgrep scan --metrics=off --config p/default --quiet'
  'zizmor --offline --no-progress'
  'govulncheck ./...'
)
# Same, for a Go module or JS package below the repo root (no cd here):
# govulncheck -C <dir> ./...  and  npm audit --prefix <dir>.
if [[ "$COMMAND" =~ ^govulncheck\ -C\ [^-\ ][^\ ]*\ \./\.\.\.$ ]] \
  || [[ "$COMMAND" =~ ^npm\ audit\ --prefix\ [^-\ ][^\ ]*(\ --omit=dev)?$ ]]; then
  exit 0
fi
for prefix in "${SCANNERS[@]}"; do
  if [ "$COMMAND" = "$prefix" ] || [[ "$COMMAND" == "$prefix "* ]]; then
    [ "$prefix" = 'govulncheck ./...' ] && [ "$COMMAND" != "$prefix" ] && block "govulncheck takes no other arguments"
    read -r -a ARGS <<<"${COMMAND#"$prefix"}"
    # ${ARGS[@]+…}: macOS bash 3.2 calls an empty array unbound under set -u.
    for a in ${ARGS[@]+"${ARGS[@]}"}; do
      [[ "$a" == -* ]] && block "no extra flags after '$prefix' (got $a)"
    done
    exit 0
  fi
done

# Dependency audits: a few read-only flags. They still run the repo's yarn
# (.yarnrc.yml yarnPath) and .npmrc: the prompt says when to skip them.
if [[ "$COMMAND" =~ ^(yarn\ audit|yarn\ npm\ audit|npm\ audit)(\ (--all|--recursive|--json|--omit=dev|--production|--environment=production))*$ ]]; then
  exit 0
fi

block "'$COMMAND' is not on the allowlist"
