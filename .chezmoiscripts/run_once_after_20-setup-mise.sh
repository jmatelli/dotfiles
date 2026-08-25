#!/usr/bin/env bash
set -euo pipefail

# mise replaces nvm/rustup/brew-ruby/brew-python: one version manager,
# global defaults here, per-project .mise.toml overrides as needed.
eval "$(mise activate bash)"

mise use --global node@lts
mise use --global go@latest
mise use --global rust@latest
mise use --global python@latest
mise use --global ruby@latest

# gofumpt: referenced by the Neovim config's Go formatter chain
# (conform.nvim), not covered by any brew formula.
mise use --global go:mvdan.cc/gofumpt@latest
