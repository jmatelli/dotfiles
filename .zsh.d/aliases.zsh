alias vim='nvim'

alias ls='exa -h --group-directories-first -1'
alias l='exa -h --group-directories-first --icons'
alias ll='exa -lah --group-directories-first --icons'

alias dotf='cd ~/.dotfiles'

# Git
alias gp='git pull'
alias gco='git co'
alias gnew='git co -b'
alias gst='git st'
alias gap='git add -p'
alias gaa='git add -A'
alias gcm='git cm'
alias gcan='git can'
alias gsta='git stash'
alias gstu='git stash -u'
alias gpu='git push'
alias gbr='git br | fzf'
alias gclean='git branch -d `git branch --merged | ag -v "\\*" | ag -v main | ag -v master | ag -v devel`'
