# Linear workspace by folder for OpenCode's git-sidebar, which reads
# LINEAR_API_KEY: the work key everywhere, the personal Heures key in the
# heures-app repo (and its .worktrees). This mirrors the linear-heures MCP
# server that heures-app's own opencode.json adds. Without
# LINEAR_API_KEY_HEURES set, LINEAR_API_KEY is left alone.

_linear_account() {
  [[ -n "${LINEAR_API_KEY_HEURES:-}" ]] || return 0
  (( ${+_LINEAR_API_KEY_DEFAULT} )) || typeset -g _LINEAR_API_KEY_DEFAULT="${LINEAR_API_KEY:-}"
  if [[ "$PWD/" == "$HOME/code/heures-app/"* ]]; then
    export LINEAR_API_KEY="$LINEAR_API_KEY_HEURES"
  elif [[ -n "$_LINEAR_API_KEY_DEFAULT" ]]; then
    export LINEAR_API_KEY="$_LINEAR_API_KEY_DEFAULT"
  else
    unset LINEAR_API_KEY
  fi
}
autoload -Uz add-zsh-hook
add-zsh-hook chpwd _linear_account
_linear_account
