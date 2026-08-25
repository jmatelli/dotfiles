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

################
# DEPENDENCIES #
################

setupBrew() {
	BREW_PACKAGES=(
		cmake
		curl
		docker
		eza
		fd
		fzf
		git
		git-delta
		go
		golangci-lint
		gzip
		jandedobbeleer/oh-my-posh/oh-my-posh
		jq
		lazygit
		lua-language-server
		luajit
		luarocks
		neovim
		python
		python3
		ripgrep
		ruby
		rustup
		stow
		the_silver_searcher
		# tmux
		tree-sitter
		unzip
		wget
		zoxide
	)

	BREW_CASKS=(
		# alacritty
		# notion
		# obsidian
		alt-tab
		discord
		firefox
		google-chrome
		google-drive
		keycastr
		kitty
		postman
		raycast
		rectangle
		slack
		visual-studio-code
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
		echo "- Installing brew casks ${BREW_CASKS[*]}..."
		brew install -q --cask ${BREW_CASKS[@]} --force
		printDone
	else
		echo "Can't install Casks on other OS than MacOS"
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
		bash-language-server
		eas-cli
		eslint
		eslint_d
		prettier
		typescript
		typescript-language-server
		yarn
	)

	[[ ! -d "$NVM_PATH" ]] && echo "- Downloading NVM" && git clone https://github.com/nvm-sh/nvm.git $NVM_PATH && printDone

	lts="$(. $NVM_PATH/nvm.sh && nvm ls-remote --lts | grep -i latest | sed -e 's/.*v//g' | sed -e 's/\..*//g' | tail -n 2)"

	echo "- Installing node latest 2 LTS versions"
	for version in $lts; do
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

	setupBrew
	setupZsh
	setupNode
	setupTerminal
	setupMisc
	setupNeovim
}

while getopts "dch" OPTION; do
	case "$OPTION" in
	d) DOTFILES_DEBUG=1 ;;
	c) INSTALL_CASKS=1 ;;
	h)
		printHelp
		exit 1
		;;
	?)
		printHelp
		exit 1
		;;
	esac
done

main
