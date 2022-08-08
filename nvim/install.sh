#!/usr/bin/sh

NVIM_PATH=~/.config/nvim-lua
export NVIM_PATH

# dependencies
# brew install golangci-lint cmake luarocks luajit wget ripgrep fd stown

# if [[ "$OSTYPE" == "darwin"* ]] then
#   if ! command -v curl &> /dev/null then
#     echo "curl is not installed"
#     exit 1
#   fi
#   echo "Installing macOS dependency manager Brew"
#   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

#   echo "Installing macOS dependencies with brew"
#   brew install neovim golangci-lint cmake luarocks luajit wget ripgrep fd stown
# fi

rm -rf $NVIM_PATH

mkdir -p $NVIM_PATH/share
mkdir -p $NVIM_PATH/nvim

stow --restow --target=$NVIM_PATH/nvim .

alias nvl='XDG_DATA_HOME=$NVIM_PATH/share XDG_CONFIG_HOME=$NVIM_PATH nvim' 

export nvl
