alias vim='nvim'

alias ls='exa -h --group-directories-first -1'
alias l='exa -h --group-directories-first --icons'
alias ll='exa -lah --group-directories-first --icons'

alias dotf='cd ~/.dotfiles'

alias lg='lazygit'

# Git
alias gp='git pull'
alias gco='git co $(git br | fzf-tmux -p --header "[Switch branches]")'
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
alias gpf='git push --force-with-lease'
alias gbr='git br | fzf'
alias gclean='git branch -d `git branch --merged | ag -v "\\*" | ag -v main | ag -v master | ag -v devel`'

function gdb() {
  git branch --merged | ag --invert-match '\*' | fzf-tmux -p --header "[Delete git branches]" --multi --preview="git log {} --" | xargs -r git branch --delete --force
}

# function gco() {
#   local branch
#   branch=$(git br | fzf-tmux --print-query -p --header "[Switch branches]" | tail -1)
#
#   if [[ $branch =~ ^ivts-[0-9]{5}(?:web|mobile)?$  ]]; then
#     git co "$branch"
#   else;
#     git co -b "$branch"
#   fi
# }

# @description:
#   This function allows the creation of aliases that push a filtered list of files to fzf and run a command on the selected files
#
# @params:
#   @regex - string, a regex to filter the list of files
#   @header - string, a description of what the command will do
#   @cmd - string, the command to run on the selected files
#   @multiple - 0 | 1, default 0, if the multiple file option should be passed to fzf
#   @style - string, default "50%,50%", the height and width of the modal
#   @preview - string, default "", if a preview should be displayed
newAlias() {
  local regex=$1
  local header=$2
  local cmd=$3
  local multiple=${4:-0}
  local preview=${5:-"bat --style=numbers --color=always --line-range :500 {}"}

  # if it is a multiple selection use `-m` flag on `fzf-tmux`,
  # then use `sed` and `tr` to format the list of filename
  # we get into a single line separated by a space
  if [[ $multiple == 1 ]]; then
    FILES=$((rg --files | ag $regex | fzf-tmux -p "90%" -m --header $header --preview $preview | sed 's/$/ /' | tr -d '\n') 2>&1)
  else;
    FILES=$((rg --files | ag $regex | fzf-tmux -p "90%" --header $header --preview $preview) 2>&1)
  fi;

  # combine the command with the list of files and store the result into a variable
  COMMAND="$cmd $FILES"
  # execute the command
  bash -c "$COMMAND"
  # add the command to bash/zsh history
  print -s "$COMMAND"
}

# Mission specific aliases
v() {
  newAlias ".*" "[NeoVim: Open file]" "nvim" 0
}

tf() {
  newAlias "\.test\.tsx?" "[NPM: test unique file]" "npm t -- -i"
}

tfs() {
  newAlias "\.test\.tsx?" "[NPM: test multiple file]" "npm t -- -i" 1
}

chroma() {
  newAlias "\.stories\.tsx?" "[Chromatic: build unique file]" "npm run chromatic -- --only-story-files"
}

chromas() {
  newAlias "\.stories\.tsx?" "[Chromatic: build multiple file]" "npm run chromatic -- --only-story-files" 1
}

alias nfv='npm run format & npm run validate'
