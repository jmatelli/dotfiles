# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
export EDITOR=/opt/homebrew/bin/nvim
export TERM=xterm-256color

export BAT_THEME="Dracula"

PROMPT_COMMAND="history -a;$PROMPT_COMMAND"
export HISTSIZE PROMPT_COMMAND

# FZF theme for tokyonight
# bg:#1a1b26
# bg+:#1a1b26
export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS' 
  --height 40% --reverse --header "[Search history]"
	--color=fg:#ffffff,bg:-1,hl:#bb9af7
	--color=fg+:#c0caf5,bg+:-1,gutter:-1,hl+:#7dcfff
	--color=info:#7aa2f7,prompt:#7dcfff,pointer:#7dcfff 
	--color=marker:#9ece6a,spinner:#9ece6a,header:#9ece6a'
export FZF_DEFAULT_COMMAND='rg --files --no-ignore-vcs --hidden'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_TMUX_OPTS=$FZF_TMUX_OPTS' 
  -p'

# NEOVIM
export NVIM_PATH="~/.config/nvim-lua"

# NVM
export NVM_DIR="$HOME/.nvm"

# Alacritty
export PATH="/Applications/Alacritty.app/Contents/MacOS:$PATH"

# Python
export PYENV_HOME="$HOME/.pyenv" 
export PATH="$PYENV_HOME/bin:$PATH" 

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"

# Rust
export PATH="$HOME/.cargo/bin:$HOME/bin:/usr/local/bin:$PATH"

# Ruby
export PATH="/opt/homebrew/opt/ruby@3.1/bin:$PATH"
export PATH="/Users/joelmatelli/.gem/ruby/2.6.0/bin:$PATH"

# Flutter
export PATH="/Users/joel_matelli/sdk/flutter/bin:$PATH"
export PATH="/Users/joel_matelli/fvm/versions/3.16.5/bin:$PATH"

# Android studio
export ANDROID_HOME="$HOME/Library/Android/sdk/"
export PATH="$ANDROID_HOME/platform-tools:$PATH"
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin/:$PATH"
export PATH="$ANDROID_HOME/build-tools/33.0.2/:$PATH"
export PATH="$ANDROID_HOME/emulator/bin64/:$PATH"
