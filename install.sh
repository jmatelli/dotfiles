#!/usr//bin/env bash

set -o errexit
set -o nounset
set -o pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No style

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
  echo -e "Dotfiles install script of ${BOLD}Joël Matelli${NC}"
  echo -e "This script will install and configure ${BOLD}ZSH${NC}, ${BOLD}terminal${NC}, ${BOLD}Git${NC}, ${BOLD}NeoVim${NC}..."
  echo "It will also install all necessary packages for a full-stack software engineer"
  echo -e "like ${BOLD}Golang${NC}, ${BOLD}Node.js${NC}, ${BOLD}Typescript${NC}, ${BOLD}Eslint${NC}, ${BOLD}prettier${NC}..."
  echo ""
  echo "Script usage: ./install.sh [-a] [-d] [-c] [-i 1] [-y] [-h]"
  echo ""
  echo -e "${GREEN}${BOLD}Options:${NC}"
  echo -e "\t${BOLD}-a${NC}\t\tRun all steps"
  echo -e "\t${BOLD}-c${NC}\t\tInstall casks"
  echo -e "\t${BOLD}-d${NC}\t\tDebug mode"
  echo -e "\t${BOLD}-i [step]${NC}\tRun specific step"
  echo -e "\t${BOLD}-y${NC}\t\tAnswer yes to all prompt"
  echo ""
  echo -e "${BLUE}${BOLD}Help:${NC}"
  echo -e "\t${BOLD}-h${NC}\t\tShow help"
}

################
# DEPENDENCIES #
################

setupBrew() {
  BREW_PACKAGES=(
    cmake
    curl
    docker
    exa
    fd
    fzf
    git
    git-delta
    go
    golangci-lint
    gzip
    jq
    lua-language-server
    luajit
    luarocks
    neovim
    python
    python3
    ripgrep
    ruby
    rustup
    starship
    stow
    the_silver_searcher
    tmux
    tree-sitter
    unzip
    wget
    zoxide
  )

  BREW_CASKS=(
    alacritty
    alt-tab
    discord
    firefox
    google-chrome
    google-drive
    keycastr
    notion
    obsidian
    raycast
    rectangle
    slack
    whatsapp
  )

  if ! command -v brew &>/dev/null; then
    echo "- Installing macOS dependency manager Brew..."
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    printDone
  else
    echo "Homebrew is already installed, moving on..."
  fi

  echo "- Updating brew..."
  brew update
  printDone

  echo "- Installing GNU coreutils..."
  brew install -q coreutils
  printDone

  echo "- Installing GNU findutils..."
  brew install -q findutils
  printDone

  echo "- Installing zsh..."
  brew install -q zsh
  printDone

  echo "- Installing brew packages ${BREW_PACKAGES[*]}..."
  brew install -q ${BREW_PACKAGES[@]}
  printDone

  echo "- Cleanup brew..."
  brew cleanup
  printDone

  if [[ $OSTYPE == 'darwin'* ]]; then
    if [[ "${INSTALL_CASKS:-0}" == "1" ]] || [[ "${ACCEPT_ALL:-0}" == "1" ]]; then
      echo "- Installing brew casks ${BREW_CASKS[*]}..."
      brew install -q --cask ${BREW_CASKS[@]} --force
      printDone
    fi
  else
    if [[ "${INSTALL_CASKS:-0}" == "1" ]] || [[ "${ACCEPT_ALL:-0}" == "1" ]]; then
      echo "Can't install Casks on other OS than MacOS"
    fi
  fi
}

#######
# ZSH #
#######

setupZsh() {
  ZSHD=$HOME/.zsh.d

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
}

setupNode() {
  NVM_PATH=$HOME/.nvm

  NODE_PACKAGES=(
    @fsouza/prettierd
    @tailwindcss/language-server
    eas-cli
    eslint
    eslint_d
    prettier
    typescript
    typescript-language-server
    yarn
  )

  [[ ! -d "$NVM_PATH" ]] && echo "- Downloading NVM" && git clone https://github.com/nvm-sh/nvm.git $NVM_PATH && printDone

  lts="$(. $NVM_PATH/nvm.sh &&  nvm ls-remote --lts | grep -i latest | sed -e 's/.*v//g' | sed -e 's/\..*//g'| tail -n 2)"
  
  echo "- Installing node latest 2 LTS versions"
  for version in $lts
  do
    echo "Installing node version $version"
    # sh -e ". $NVM_PATH/nvm.sh && nvm ls-remote --lts=$lts"
    . $NVM_PATH/nvm.sh && nvm install "$version"
  done
  printDone

  echo "- Select latest LTS version of node to use"
  . $NVM_PATH/nvm.sh && nvm use --lts
  printDone

  echo "- Installing node global packages ${NODE_PACKAGES[*]}"
  npm install -g "${NODE_PACKAGES[@]}"
  printDone
}

#########
# Terminal #
#########

setupTerminal() {
  [[ ! -d "$HOME/fonts" ]] && mkdir -p "$HOME/fonts"
  [[ ! -d "$HOME/fonts/nerd-fonts" ]] && echo "- Downloading Nerd Fonts" && git clone https://github.com/ryanoasis/nerd-fonts.git $HOME/fonts/nerd-fonts && printDone

  echo "- Installing required Nerd Fonts"
  # $HOME/fonts/nerd-fonts/install.sh meslo
  "$HOME"/fonts/nerd-fonts/install.sh Hack
  printDone

  # see https://apple.stackexchange.com/questions/266333/how-to-show-italic-in-vim-in-iterm2
  echo "- Linking Terminfo files to ${HOME}/terminfo"
  tic -o ~/.terminfo "$HOME/terminfo/xterm-256color.terminfo.txt"
  tic -o ~/.terminfo "$HOME/terminfo/tmux.terminfo.txt"
  tic -o ~/.terminfo "$HOME/terminfo/tmux-256color.terminfo.txt"
  printDone
}

########
# MISC #
########

setupMisc() {
  read gitemail

  echo "- Setting up git email"
  git config --global user.email $gitemail
}

#######
# VIM #
#######

setupNeovim() {
  NVIM_PATH=$HOME/.config/nvim

  echo "- Clear previous config at '${NVIM_PATH}'"
  rm -rf $NVIM_PATH
  rm -rf $HOME/.local/share/nvim
  printDone
}

conditionalRun() {
  if [[ "${ACCEPT_ALL:-0}" != "1" ]]; then
    while true; do
      read -rp "$1, proceed? (y/n)" yn
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
  conditionalRun "You are about to setup iTerm" setupTerminal
  conditionalRun "You are about to setup Git..." setupMisc
  conditionalRun "You are about to setup NeoVim" setupNeovim
}

partialRun() {
  PS3="Choose which step to run: "
  steps=("Brew" "ZSH" "Node" "Iterm" "Misc" "NeoVim" "All")
  select step in "${steps[@]}"; do
    case $step in
      "Brew")
        echo ""
        setupBrew
        exit
        ;;
      "ZSH")
        echo ""
        setupZsh
        exit
        ;;
      "Node")
        echo ""
        setupNode
        exit
        ;;
      "Iterm")
        echo ""
        setupTerminal
        exit
        ;;
      "Misc")
        echo ""
        setupMisc
        exit
        ;;
      "NeoVim")
        echo ""
        setupNeovim
        exit
        ;;
      "All")
        echo ""
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
    set -o xtrace
  fi

  if [[ "$OSTYPE" != "darwin"* ]]; then
    printError "This script only works on MacOS right now..."
    exit 1
  fi

  if [[ "${INSTALL_STEP:-0}" != "7" ]] && [[ "${INSTALL_STEP:-0}" != "0" ]]; then
    [[ "${INSTALL_STEP:-0}" = "1" ]] && conditionalRun "You are about to setup brew and install all neede formulae" setupBrew
    [[ "${INSTALL_STEP:-0}" = "2" ]] && conditionalRun "You are about to setup ZSH" setupZsh
    [[ "${INSTALL_STEP:-0}" = "3" ]] && conditionalRun "You are about to setup Node" setupNode
    [[ "${INSTALL_STEP:-0}" = "4" ]] && conditionalRun "You are about to setup Terminal" setupTerminal
    [[ "${INSTALL_STEP:-0}" = "5" ]] && conditionalRun "You are about to setup Git, tmux..." setupMisc
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
