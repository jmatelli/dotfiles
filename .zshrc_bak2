source $HOME/.zsh.d/theme.zsh

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

zstyle ':omz:update' mode reminder  # just remind me to update when it's time
zstyle ':completion:*' menu select # added for zsh-z

source $ZSH/oh-my-zsh.sh

HISTSIZE=30000
setopt INC_APPEND_HISTORY

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
eval "$(pyenv init --path)" 
eval "$(pyenv init -)"

source $HOME/.zsh.d/aliases.zsh

if ! brew ls --version ruby >/dev/null; then
  echo ""
  export PATH=$(brew --prefix ruby)/bin:$(ruby -e 'puts Gem.bindir'):$PATH
fi

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
[ -f "$HOME/.sdkman/bin/sdkman-init.sh" ] && source "$HOME/.sdkman/bin/sdkman-init.sh"


eval "$(starship init zsh)"
