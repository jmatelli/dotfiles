#!/usr/bin/env bash
#
# Bootstraps a machine: git -> native package manager -> chezmoi -> apply.
# Everything else (package lists, dotfile templating, machine prompts) lives
# in the chezmoi source state and is OS-branched there, not here.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/jmatelli/dotfiles/main/install.sh | bash
#
# Override the source repo/branch (e.g. to test a local checkout or a
# feature branch before merging):
#   DOTFILES_REPO=/path/to/local/checkout DOTFILES_BRANCH=my-branch ./install.sh

set -euo pipefail

DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/jmatelli/dotfiles.git}"
DOTFILES_BRANCH="${DOTFILES_BRANCH:-main}"
DOTFILES_SOURCE_DIR="${DOTFILES_SOURCE_DIR:-$HOME/.dotfiles}"

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

info() { echo -e "${GREEN}==>${NC} $1"; }
fail() {
  echo -e "${RED}✕${NC} $1" >&2
  exit 1
}

OS="$(uname -s)"

case "$OS" in
Darwin)
  PLATFORM="macos"
  ;;
Linux)
  # shellcheck disable=SC1091
  . /etc/os-release
  case "${ID:-}${ID_LIKE:-}" in
  *arch*)
    PLATFORM="arch"
    ;;
  *debian*)
    PLATFORM="debian"
    ;;
  *)
    fail "Unsupported Linux distro (ID=${ID:-unknown}). This script supports Arch/Omarchy and Debian/Ubuntu."
    ;;
  esac
  ;;
*)
  fail "Unsupported OS: $OS"
  ;;
esac

info "Detected platform: $PLATFORM"

case "$PLATFORM" in
macos)
  if ! command -v brew &>/dev/null; then
    # Homebrew's installer also installs the Xcode Command Line Tools (git).
    # Run non-interactively it never asks for a password (sudo -n), so on a
    # fresh Mac, where it must create /opt/homebrew, it would abort: ask for
    # the password once here, then it reuses it.
    info "Installing Homebrew (and the Xcode Command Line Tools); enter your Mac password..."
    sudo -v
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  # Apple silicon, else Intel.
  for brew in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    if [ -x "$brew" ]; then
      eval "$("$brew" shellenv)"
      break
    fi
  done

  info "Installing chezmoi..."
  brew install -q chezmoi
  ;;

arch)
  if ! command -v git &>/dev/null; then
    info "Installing git..."
    sudo pacman -Sy --noconfirm --needed git
  fi

  info "Installing chezmoi..."
  sudo pacman -Sy --noconfirm --needed chezmoi
  ;;

debian)
  if ! command -v git &>/dev/null; then
    info "Installing git..."
    sudo apt-get update
    sudo apt-get install -y git curl
  fi

  info "Installing chezmoi..."
  sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
  export PATH="$HOME/.local/bin:$PATH"
  ;;
esac

info "Running chezmoi init --apply ($DOTFILES_REPO @ $DOTFILES_BRANCH -> $DOTFILES_SOURCE_DIR)..."
chezmoi init --apply --branch "$DOTFILES_BRANCH" --source "$DOTFILES_SOURCE_DIR" "$DOTFILES_REPO"

info "Done. Open a new terminal, then finish the manual steps in the README:"
echo "  https://github.com/jmatelli/dotfiles#after-the-install"
echo "  (GitHub logins, secrets, Claude Code, OpenCode, Herdr layout)"
