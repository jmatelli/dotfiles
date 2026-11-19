#!/bin/bash

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command')
CWD=$(echo "$INPUT" | jq -r '.cwd')

# leguin: no commands are blocked in this repo.
if [[ "$CWD" == "$HOME"/code/leguin || "$CWD" == "$HOME"/code/leguin/* ]]; then
  exit 0
fi

# TypeTUI: allow a plain, standalone `git push`. Force pushes, deletes and
# chained commands (&&, ;, |) fall through to the checks below and stay blocked.
if [[ "$CWD" == "$HOME"/code/TypeTUI* ]] \
   && echo "$COMMAND" | grep -qE "^[[:space:]]*git push" \
   && ! echo "$COMMAND" | grep -qE -- "--force|--force-with-lease|--delete|--mirror|(^|[[:space:]])-[a-zA-Z]*[fd]|\+[^ ]*|&&|;|\||\`|\\$\("; then
  exit 0
fi

DANGEROUS_PATTERNS=(
  "git push"
  "git reset --hard"
  "git clean -fd"
  "git clean -f"
  "git branch -D"
  "git checkout \."
  "git restore \."
  "push --force"
  "reset --hard"
)

for pattern in "${DANGEROUS_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qE "$pattern"; then
    echo "BLOCKED: '$COMMAND' matches dangerous pattern '$pattern'. The user has prevented you from doing this." >&2
    exit 2
  fi
done

exit 0
