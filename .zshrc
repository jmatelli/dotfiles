# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
export PATH=$HOME/.cargo/bin:$HOME/bin:/usr/local/bin:$PATH

source $HOME/.zsh.d/theme.zsh

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
export EDITOR=/opt/homebrew/bin/nvim
export TERM=xterm-256color-italic

source ~/antigen.zsh

antigen use oh-my-zsh
# antigen theme "robbyrussell"
# antigen theme "af-magic"

antigen bundle git
antigen bundle brew
antigen bundle npm
antigen bundle macos
antigen bundle tmuxinator
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle lukechilds/zsh-better-npm-completion
antigen bundle greymd/docker-zsh-completion
antigen bundle command-not-found
antigen bundle agkozak/zsh-z

antigen apply

ZSH_THEME="powerlevel10k/powerlevel10k"
export BAT_THEME="Dracula"

zstyle ':omz:update' mode reminder  # just remind me to update when it's time
zstyle ':completion:*' menu select # added for zsh-z

source $ZSH/oh-my-zsh.sh

HISTSIZE=30000
setopt INC_APPEND_HISTORY
PROMPT_COMMAND="history -a;$PROMPT_COMMAND"
export HISTSIZE PROMPT_COMMAND

# Use Ctrl-z to switch between vim and cli
fancy-ctrl-z () {
  if [[ $#BUFFER -eq 0 ]]; then
    BUFFER="fg"
    zle accept-line
  else
    zle push-input
    zle clear-screen
  fi
}
zle -N fancy-ctrl-z
bindkey '^Z' fancy-ctrl-z

# useful only for Mac OS Silicon M1, 
# still working but useless for the other platforms
docker() {
 if [[ `uname -m` == "arm64" ]] && [[ "$1" == "run" || "$1" == "build" ]]; then
    /usr/local/bin/docker "$1" --platform linux/amd64 "${@:2}"
  else
     /usr/local/bin/docker "$@"
  fi
}

export PYENV_ROOT="$HOME/.pyenv" 
export PATH="$PYENV_ROOT/bin:$PATH" 
eval "$(pyenv init --path)" 
eval "$(pyenv init -)"

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


# VIM
export NVIM_PATH=~/.config/nvim-lua

source $HOME/.zsh.d/aliases.zsh

if ! brew ls --version ruby >/dev/null; then
  echo ""
  export PATH=$(brew --prefix ruby)/bin:$(ruby -e 'puts Gem.bindir'):$PATH
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# place this after nvm initialization!
autoload -U add-zsh-hook
load-nvmrc() {
  local node_version="$(nvm version)"
  local nvmrc_path="$(nvm_find_nvmrc)"

  if [ -n "$nvmrc_path" ]; then
    local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

    if [ "$nvmrc_node_version" = "N/A" ]; then
      nvm install
    elif [ "$nvmrc_node_version" != "$node_version" ]; then
      nvm use
    fi
  elif [ "$node_version" != "$(nvm version default)" ]; then
    echo "Reverting to nvm default version"
    nvm use default
  fi
}
add-zsh-hook chpwd load-nvmrc
load-nvmrc

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"
# pnpm end
# source /Users/joelmatelli/.config/broot/launcher/bash/br

export ANDROID_HOME=$HOME/Library/Android/sdk/
export PATH=$ANDROID_HOME/platform-tools:$PATH

export PATH="/opt/homebrew/opt/ruby@3.1/bin:$PATH"
export PATH="/Users/joelmatelli/.gem/ruby/2.6.0/bin:$PATH"
