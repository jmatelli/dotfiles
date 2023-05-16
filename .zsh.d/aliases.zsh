alias vim='nvim'

alias ls='exa -h --group-directories-first -1'
alias l='exa -h --group-directories-first --icons'
alias ll='exa -lah --group-directories-first --icons'

alias dotf='cd ~/.dotfiles'

# Git
alias gp='git pull'
alias gco='git co $(git br | fzf)'
alias gcod='git co develop'
alias gcom='git co master'
alias gnew='git co -b'
alias gst='git st'
alias gd='git diff'
alias gl='git lg'
alias gll='git ll'
alias gap='git add -p'
alias gaa='git add -A'
alias gcm='git cm'
alias gcan='git can'
alias gsta='git stash'
alias gstu='git stash -u'
alias gpu='git push'
alias gbr='git br | fzf'
alias gclean='git branch -d `git branch --merged | ag -v "\\*" | ag -v main | ag -v master | ag -v devel`'


# Mission specific aliases
alias tf='npm t -- -i $(rg --files | ag "\.test\.tsx?" | fzf-tmux -p --header "[NPM: test unique file]")' # tf = test file
alias tfs='npm t -- -i $(rg --files | ag "\.test\.tsx?" | fzf-tmux -p -m --header "[NPM: test multiple files] (use <TAB> to select and <SHIFT>+<TAB> to unselect)")' # tfs = test files

alias v='rg --files | fzf-tmux -p | xargs nvim'
alias chroma='rg --files | ag "\.stories\.tsx?" | fzf-tmux -p --header "[Chromatic: build unique file]" | xargs npm run chromatic -- --only-story-files'
alias chromas='rg --files | ag "\.stories\.tsx?" | fzf-tmux -p -m --header "[Chromatic: build multiple files]" | xargs npm run chromatic -- --only-story-files'
