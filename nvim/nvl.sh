#!/usr/bin/sh

NVIM_PATH=~/.config/nvim-beginner
export NVIM_PATH

alias nvl='XDG_DATA_HOME=$NVIM_PATH/share XDG_CONFIG_HOME=$NVIM_PATH nvim' 
export nvl

nvl
