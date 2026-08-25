eval "$(/opt/homebrew/bin/brew shellenv)"

# set up zinit directory
ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"

# clone zinit if it doesn't exist
if [ ! -d "$ZINIT_HOME" ]; then
  mkdir -p "$(dirname "$ZINIT_HOME")"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# source zinit
source "$ZINIT_HOME/zinit.zsh"

# add zinit plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab
zinit light greymd/docker-zsh-completion
zinit light lukechilds/zsh-nvm
zinit light lukechilds/zsh-better-npm-completion

# add zinit snippets
zinit snippet OMZP::git
zinit snippet OMZP::brew
zinit snippet OMZP::npm
zinit snippet OMZP::sudo
zinit snippet OMZP::command-not-found

# load zfunc
fpath=(~/.zfunc $fpath)

# load completions
autoload -U compinit && compinit

zinit cdreplay -q

# key bindings
bindkey '^y' autosuggest-accept
bindkey '^n' history-search-forward
bindkey '^p' history-search-backward
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search # Up
bindkey "^[[B" down-line-or-beginning-search # Down

# history
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# aliases
source $HOME/.zsh.d/aliases.zsh
# secrets
source $HOME/.zsh.d/secrets.zsh

# Shell integrations
eval "$(fzf --zsh)"
eval "$(zoxide init zsh)"
eval "$(oh-my-posh init zsh --config $HOME/.config/oh-my-posh/codikos.omp.toml)"

## [Completion]
## Completion scripts setup. Remove the following line to uninstall
[[ -f /Users/techlead/.dart-cli-completion/zsh-config.zsh ]] && . /Users/techlead/.dart-cli-completion/zsh-config.zsh || true
## [/Completion]

# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/techlead/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions

# Added by Antigravity
export PATH="/Users/techlead/.antigravity/antigravity/bin:$PATH"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/techlead/.lmstudio/bin"
# End of LM Studio CLI section

