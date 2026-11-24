#!/bin/bash
#
# PreToolUse hook for the subagents (code-reviewer, deep-reviewer,
# performance-optimizer, security-auditor, qa-tester), set in each agent's
# frontmatter so it runs only inside that agent. Claude Code's agent files
# can't limit Bash to some commands; this does what OpenCode's permission
# rules do for the same agents (dot_config/opencode/agents/).
#
# Usage: agent-shell-allowlist.sh <git|security|qa>
#   git       git diff / log / show only
#   security  those, plus the scanners in their fixed forms (see SCANNERS)
#   qa        git diff / log / show / status, plus the project's lint, type
#             and test commands (see the qa block)
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

if [ "$MODE" = qa ]; then
  [[ "$COMMAND" =~ ^git(\ -C\ [^\ ]+)?\ status(\ |$) ]] && exit 0
  # The project's checks and tests, optionally in a subproject (yarn --cwd,
  # npm --prefix, make -C, go -C, since cd can't be chained). Running tests
  # runs the project's code, so this keeps the agent on task (no installs,
  # git writes, rm, curl…); it isn't a sandbox.
  for w in "${WORDS[@]}"; do
    case "$w" in
      # also --updateSnapshot, --update-snapshots, -uall, --u (= -u to yargs/mri)
      -u* | --u | --u=* | --update*)  # -u* covers go's -update
        block "$w updates snapshots or golden files: report outdated ones instead" ;;
      -exec | -exec=* | -toolexec* | -vettool* | --script-shell*)
        block "$w runs another program" ;;
      # Rewrite sources (eslint/prettier --fix, tsc emit) or write files anywhere.
      --fix* | --write | --outDir* | --outFile* | --declarationDir* | -b | --build* | --init \
        | --output* | -o | -o=* | -outputdir* | -coverprofile* | -cpuprofile* | -memprofile* \
        | -blockprofile* | -mutexprofile* | -trace*)
        block "$w writes or rewrites files outside the tests" ;;
    esac
    # Grouped short flags hiding -u (-iu, -wu) for the JS runners; not go,
    # whose single-dash flags are words (-run, -count).
    if [ "${WORDS[0]}" != go ] && [[ "$w" =~ ^-[A-Za-z]*u[A-Za-z]*$ ]]; then
      block "$w may include -u (update snapshots)"
    fi
  done
  is_script() {
    case "${1:-}" in
      lint | tsc | typecheck | test | test:?* | e2e) return 0 ;;
    esac
    return 1
  }
  qa_dir() {
    [ -n "${1:-}" ] && [[ "$1" != -* ]] || block "the directory after ${2} must be a plain path"
  }
  set -- "${WORDS[@]}"
  TOOL=$1
  shift
  case "$TOOL" in
    yarn) [ "${1:-}" = --cwd ] && { qa_dir "${2:-}" --cwd; shift 2; } ;;
    npm) [ "${1:-}" = --prefix ] && { qa_dir "${2:-}" --prefix; shift 2; } ;;
    make | go) [ "${1:-}" = -C ] && { qa_dir "${2:-}" -C; shift 2; } ;;
  esac
  SUB=${1:-}
  case "$TOOL" in
    yarn) is_script "$SUB" || { [ "$SUB" = playwright ] && [ "${2:-}" = test ]; } ;;
    npm) [ "$SUB" = test ] || { [ "$SUB" = run ] && is_script "${2:-}"; } ;;
    # One target, then only -k / -jN: make's other flags and VAR=value
    # overrides (-f, -e, --eval, SHELL=…) change what runs.
    make) case "$SUB" in test | test-?* | lint) true ;; *) false ;; esac \
      && shift && for a in "$@"; do [[ "$a" =~ ^(-k|-j[0-9]*)$ ]] || block "make takes one target, then only -k or -jN (got $a)"; done ;;
    go) case "$SUB" in test | vet) true ;; *) false ;; esac ;;
    maestro) [ "$SUB" = test ] ;;
    *) false ;;
  esac && exit 0
  block "'$COMMAND' is not on the allowlist (git diff/log/show/status, and the lint/tsc/test scripts, make test/lint, go test/vet, maestro test)"
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
