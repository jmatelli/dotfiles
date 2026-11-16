#!/usr/bin/env bash
set -euo pipefail

# TPM manages its own plugins directory (.chezmoiignore excludes
# .config/tmux/plugins/** from chezmoi), so nothing installs it on a fresh
# machine unless something does it explicitly - this is that step. TPM
# itself confirms it doesn't need a running tmux server to install plugins
# (see its bin/install_plugins), so this can run as a plain bootstrap step.
TPM_DIR="$HOME/.config/tmux/plugins/tpm"

# tmux is only for the Linux profiles; Herdr is the terminal on macOS.
if [ "$(uname)" = Darwin ]; then
  exit 0
fi

# TPM's installer still calls the tmux binary; without tmux (its package
# failed or isn't in this OS's list) skip with a warning rather than abort the
# whole chezmoi apply. A later apply after installing tmux runs this again.
if ! command -v tmux >/dev/null 2>&1; then
  echo "Warning: tmux isn't installed; skipping its plugins (install tmux, then: chezmoi apply)" >&2
  exit 0
fi

if [ ! -d "$TPM_DIR" ]; then
  git clone --depth 1 https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi

"$TPM_DIR/bin/install_plugins"
