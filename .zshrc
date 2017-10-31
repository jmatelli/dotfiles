export ZSH=$HOME/.oh-my-zsh
export EDITOR=/usr/bin/nvim

source $HOME/bin//antigen.zsh

antigen use oh-my-zsh
#antigen theme "robbyrussell"
antigen theme "robbyrussell"

antigen bundle git
antigen bundle tmuxinator
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle lukechilds/zsh-better-npm-completion
antigen bundle greymd/docker-zsh-completion
antigen bundle command-not-found

antigen apply

# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias vim="vim -u ~/.nvimrc"
alias mugiwara="ssh tellijo@163.172.211.59 -p 54321"
alias mw=mugiwara
alias nas="ssh tellijo@192.168.1.96 -p 6969"

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

# Avoid changing window name in tmux
DISABLE_AUTO_TITLE="true"

# use node executable without installing them global
if echo $PATH | grep node_modules/.bin >/dev/null 2>/dev/null; then
     true
else
    export PATH="$PATH:node_modules/.bin:$HOME/bin"
fi

export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/platform-tools

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
