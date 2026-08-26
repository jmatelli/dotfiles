#!/usr/bin/env bash
set -euo pipefail

# TPM manages its own plugins directory (.chezmoiignore excludes
# .config/tmux/plugins/** from chezmoi), so nothing installs it on a fresh
# machine unless something does it explicitly - this is that step. TPM
# itself confirms it doesn't need a running tmux server to install plugins
# (see its bin/install_plugins), so this can run as a plain bootstrap step.
TPM_DIR="$HOME/.config/tmux/plugins/tpm"

if [ ! -d "$TPM_DIR" ]; then
  git clone --depth 1 https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi

"$TPM_DIR/bin/install_plugins"
