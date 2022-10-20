#!/bin/bash

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
BOLD='\033[1m'

DOTFILES_PATH=$HOME/.dotfiles

DOTFILES_DEBUG=""
INSTALL_CASKS=""
ACCEPT_ALL=""
INSTALL_STEP=""

printError() {
  echo ""
  echo -e "\t${RED}✕${NC} $1" >&2
  echo ""
}

printDone() {
  echo ""
  echo -e "\t${GREEN}✓${NC} Done\n"
  echo ""
}

printSuccess() {
  echo -e "${GREEN}✓${NC} $1"
}

printHelp() {
  echo ""
  echo "Script usage: ./install.sh [-d] [-c] [-h]"
  echo ""
  echo "Options:"
  echo -e "\t-a\t\tRun all steps"
  echo -e "\t-c\t\tInstall casks"
  echo -e "\t-d\t\tDebug mode"
  echo -e "\t-i [step]\tRun specific step"
  echo -e "\t-y\t\tAnswer yes to all prompt"
  echo ""
  echo "Help:"
  echo -e "\t-h\t\tShow help"
}

################
# DEPENDENCIES #
################

setupBrew() {
  BREW_PACKAGES=(
    cmake
    docker
    exa
    fd
    fzf
    git
    git-delta
    go
    golangci-lint
    jq
    lua-language-server
    luajit
    luarocks
    neovim
    python
    python3
    ripgrep
    ruby
    stow
    the_silver_searcher
    tmux
    tree-sitter
    wget
  )

  BREW_CASKS=(
    # alfred
    alt-tab
    discord
    # firefox
    # google-chrome
    # google-drive
    # iterm2
    keycastr
    messenger
    notion
    rectangle
    # slack
    # spotify
    # whatsapp
  )

  if ! command -v brew &>/dev/null; then
    echo "- Installing macOS dependency manager Brew"
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    printDone
  else
    echo "Homebrew is already installed"
  fi

  echo "- Updating brew"
  brew update
  printDone

  echo "- Installing GNU coreutils"
  brew install -q coreutils
  printDone

  echo "- Installing GNU findutils"
  brew install -q findutils
  printDone

  echo "- Installing zsh"
  brew install -q zsh
  printDone

  echo "- Installing brew packages"
  brew install -q ${BREW_PACKAGES[@]}
  printDone

  echo "- Cleanup brew"
  brew cleanup
  printDone

  if [[ "${INSTALL_CASKS:-0}" == "1" ]] || [[ "${ACCEPT_ALL:-0}" == "1" ]]; then
    echo "- Installing brew casks"
    brew install -q --cask ${BREW_CASKS[@]}
    printDone
  fi
}

#######
# ZSH #
#######

setupZsh() {
  ZSHD=$HOME/.zsh.d

  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    echo "- Oh My ZSH folder already exists, removing it"
    rm -rf $HOME/.oh-my-zsh
    printDone
  fi

  echo "- Installing Oh My ZSH"
  sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" "" --keep-zshrc --unattended
  printDone

  if [[ ! -d "$ZSHD" ]]; then
    echo "- Creating ${ZSHD} directory"
    mkdir -p $ZSHD
    printDone
  else
    echo "- Directory ${ZSHD} already exists, removing and recreating it now"
    rm -rf $ZSHD
    mkdir -p $ZSHD
    printDone
  fi

  echo "- Linking ZSH files to ${ZSHD}"
  stow --restow --target=$HOME/.zsh.d .zsh.d
  printDone

  ZSHRC=$HOME/.zshrc

  echo "- Linking .zshrc"
  ln -fs $DOTFILES_PATH/.zshrc $ZSHRC
  printDone

  ZSH_CUSTOM=$HOME/.oh-my-zsh/custom
  POWERLEVEL=$ZSH_CUSTOM/themes/powerlevel10k
  if [[ -d "$POWERLEVEL" ]]; then
    echo "- Powerlevel10k already installed, removing it"
    rm -rf $POWERLEVEL
    printDone
  fi

  echo "- Installing powerlevel10k"
  git clone https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k
  printDone

  echo "- Installing antigen"
  curl -L git.io/antigen > antigen.zsh
  printDone

  zsh
}

#########
# iTerm #
#########

setupIterm() {
  [[ ! -d "$HOME/fonts" ]] && mkdir -p $HOME/fonts
  [[ ! -d "$HOME/fonts/nerd-fonts" ]] && echo "- Downloading Nerd Fonts" && git clone https://github.com/ryanoasis/nerd-fonts.git $HOME/fonts/nerd-fonts && printDone

  echo "- Moving nerd fonts to ~/Library/Fonts folder"
  $HOME/fonts/nerd-fonts/install.sh meslo
  printDone

  echo "- Linking iTerm2 profile"
  ln -sf $DOTFILES_PATH/Profiles.json $HOME/Library/Application\ Support/iTerm2/DynamicProfiles/Profiles.json
  printDone
}

########
# MISC #
########

setupMisc() {
  [[ ! -f "$HOME/.gitconfig" ]] && echo "- Link git configuration to ~/.gitconfig" && ln -sf $DOTFILES_PATH/.gitconfig $HOME/.gitconfig && printDone
  [[ ! -f "$HOME/.tmux.conf" ]] && echo "- Link tmux configuration to ~/.tmux.conf" && ln -sf $DOTFILES_PATH/.tmux.conf $HOME/.tmux.conf && printDone
}

#######
# VIM #
#######

setupNeovim() {
  NVIM_PATH=$HOME/.config/nvim-lua

  echo "- Clear previous config at '${NVIM_PATH}'"
  rm -rf $NVIM_PATH
  printDone

  echo "- Create folder '${NVIM_PATH}/share'"
  mkdir -p $NVIM_PATH/share
  printDone

  echo "- Create folder '${NVIM_PATH}/nvim'"
  mkdir -p $NVIM_PATH/nvim
  printDone

  echo "- Link NeoVim configuration to '${NVIM_PATH}/nvim'"
  stow --restow --target=$NVIM_PATH/nvim nvim
  printDone

  printSuccess "NeoVim was installed successfuly."
  echo ""
  echo -e "When you run ${BOLD}NeoVim${NC} for the first time packer.nvim will install all packages:"
  echo ""
  echo -e "\t${BOLD}$ nvl${NC}"
  echo ""
  echo -e "You will need to quit ${BOLD}NeoVim${NC} and restart it to see changes"
  echo -e "Once ${BOLD}NeoVim${NC} is openned again, run the following command:"
  echo ""
  echo -e "\t${BOLD}:Mason<Enter>${NC}"
  echo ""
  echo "Now you are all set to start coding to your heart content ❤️  "
}

conditionalRun() {
  if [[ "${ACCEPT_ALL:-0}" != "1" ]]; then
    while true; do
      read -p "$1, proceed? (y/n)" yn
      case $yn in
        [Yy]* ) $2; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
      esac
    done
  else
    $2
  fi
}

setupAll() {
  conditionalRun "You are about to setup brew and install all neede formulae" setupBrew
  conditionalRun "You are about to setup ZSH" setupZsh
  conditionalRun "You are about to setup Node" setupNode
  conditionalRun "You are about to setup iTerm" setupIterm
  conditionalRun "You are about to setup Git..." setupMisc
  conditionalRun "You are about to setup NeoVim" setupNeovim
}

partialRun() {
  PS3="Choose which step to run: "
  steps=("Brew" "ZSH" "Node" "Iterm" "Misc" "NeoVim" "All")
  select step in "${steps[@]}"; do
    case $step in
      "Brew")
        setupBrew
        exit
        ;;
      "ZSH")
        setupZsh
        exit
        ;;
      "Node")
        setupNode
        exit
        ;;
      "Iterm")
        setupIterm
        exit
        ;;
      "Misc")
        setupMisc
        exit
        ;;
      "NeoVim")
        setupNeovim
        exit
        ;;
      "All")
        setupAll
        exit
        ;;
      *) echo "Invalid option $REPLY" ;;
    esac
  done
}

main() {
  if [[ "${DOTFILES_DEBUG:-0}" == "1" ]]; then
    echo "[Running on debug mode]"
    echo ""
    set -x
  fi

  if [[ "$OSTYPE" != "darwin"* ]]; then
    printError "This script only works on MacOS right now..."
    exit 1
  fi

  if [[ "${INSTALL_STEP:-0}" != "7" ]] && [[ "${INSTALL_STEP:-0}" != "0" ]]; then
    [[ "${INSTALL_STEP:-0}" = "1" ]] && conditionalRun "You are about to setup brew and install all neede formulae" setupBrew
    [[ "${INSTALL_STEP:-0}" = "2" ]] && conditionalRun "You are about to setup ZSH" setupZsh
    [[ "${INSTALL_STEP:-0}" = "3" ]] && conditionalRun "You are about to setup Node" setupNode
    [[ "${INSTALL_STEP:-0}" = "4" ]] && conditionalRun "You are about to setup iTerm" setupIterm
    [[ "${INSTALL_STEP:-0}" = "5" ]] && conditionalRun "You are about to setup Git..." setupMisc
    [[ "${INSTALL_STEP:-0}" = "6" ]] && conditionalRun "You are about to setup NeoVim" setupNeovim
    exit
  fi

  if [[ "${INSTALL_STEP:-0}" = "7" ]]; then
    setupAll
  else
    partialRun
  fi
}

while getopts "dcyhai:" OPTION; do
  case "$OPTION" in
    d) DOTFILES_DEBUG=1 ;;
    c) INSTALL_CASKS=1 ;;
    y) ACCEPT_ALL=1 ;;
    a) INSTALL_STEP=7 ;;
    i) INSTALL_STEP="${OPTARG}" ;;
    h)
      printHelp
      exit 1
      ;;
    ?)
      printHelp
      exit 1
  esac
done

main
