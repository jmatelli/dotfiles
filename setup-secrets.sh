#!/usr/bin/env bash
#
# Prompts for commonly-used secrets and appends any that are missing to
# ~/.zsh.d/secrets.zsh. Not managed by chezmoi, not run by install.sh -
# run this yourself, whenever, to fill in or add to your local secrets.
# Safe to re-run: already-set variables are left untouched and skipped.
#
# Add a new commonly-used secret later by adding one line to VARS below.

set -euo pipefail

SECRETS_FILE="$HOME/.zsh.d/secrets.zsh"

VARS=(
  "GITHUB_PERSONAL_ACCESS_TOKEN|GitHub personal access token"
  "ANTHROPIC_API_KEY|Anthropic API key"
  "LINEAR_API_KEY|Linear API key"
)

mkdir -p "$(dirname "$SECRETS_FILE")"
touch "$SECRETS_FILE"
chmod 600 "$SECRETS_FILE"

for entry in "${VARS[@]}"; do
  var="${entry%%|*}"
  label="${entry#*|}"

  if grep -q "^export ${var}=" "$SECRETS_FILE" 2>/dev/null; then
    echo "✓ ${var} already set, skipping"
    continue
  fi

  read -r -s -p "Enter ${label} (${var}), leave blank to skip: " value
  echo
  if [[ -z "$value" ]]; then
    echo "- skipped ${var}"
    continue
  fi

  echo "export ${var}=\"${value}\"" >>"$SECRETS_FILE"
  echo "+ saved ${var}"
done

echo "Done. Re-run this script any time to add a variable you skipped or a new one added to VARS."
