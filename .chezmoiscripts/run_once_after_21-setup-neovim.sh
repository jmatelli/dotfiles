#!/usr/bin/env bash
set -euo pipefail

# On macOS, neovim itself is provisioned via bob (a Neovim version manager)
# rather than a plain brew formula - this actually installs/switches to a
# working nvim binary, not just the version manager.
if command -v bob &>/dev/null; then
  bob use stable
fi
