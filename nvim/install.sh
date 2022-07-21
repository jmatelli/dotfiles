#!/usr/bin/sh

NVIM_PATH=~/.config/nvim-lua
export NVIM_PATH

rm -rf $NVIM_PATH

mkdir -p $NVIM_PATH/share
mkdir -p $NVIM_PATH/nvim

stow --restow --target=$NVIM_PATH/nvim .

alias nvl='XDG_DATA_HOME=$NVIM_PATH/share XDG_CONFIG_HOME=$NVIM_PATH nvim' 

export nvl
