# secret <entry>: the first line of a pass entry, for use inside a command so
# the value never sits on the command line:
#
#   curl -H "Authorization: Bearer $(secret team/yaarz/api-token)" …
#   STRIPE_API_KEY=$(secret team/yaarz/stripe-test) yarn dev
#
# History (zsh and atuin) keeps "$(secret …)", not the value. This keeps
# secrets out of history, logs and transcripts; it isn't a wall against
# agents: while gpg-agent has the key unlocked (cached after you type the
# passphrase), any process of yours can run `pass show`, agent shells too.
# Tab completes entry names. Add an entry with `pass insert <entry>`.
secret() {
  emulate -L zsh
  if (( $# != 1 )); then
    print -u2 "usage: secret <pass entry>   (entries: pass ls)"
    return 2
  fi
  local value
  value=$(pass show -- "$1") || return
  value=${value%%$'\n'*}
  if [[ -z $value ]]; then
    print -u2 "secret: the first line of $1 is empty"
    return 1
  fi
  print -rn -- "$value"
}

_secret() {
  (( CURRENT == 2 )) || return 1
  local store=${PASSWORD_STORE_DIR:-$HOME/.password-store}
  local -a entries
  entries=($store/**/*.gpg(N:r))
  entries=(${entries#$store/})
  _multi_parts / entries
}
compdef _secret secret

# zsh's own history (~/.zsh_history, the up arrow) skips the same commands
# atuin's history_filter does (~/.config/atuin/config.toml): ones holding a
# literal token, JWT or password. Values from $VAR or $(secret …) are kept.
# A skipped command stays in this shell's memory until the next one, so a
# typo can still be fixed with the up arrow.
_secret_history_filter() {
  emulate -L zsh
  setopt extended_glob
  local line=${1%%$'\n'}
  local lower=${(L)line}
  local q=$'["\']'
  [[ $lower =~ "(token|secret|password|passwd|api_key|apikey)=${q}?([^\$\"' 	]|\\\$')" ]] && return 1
  [[ $lower =~ 'authorization: *(bearer|basic|token) +[^$ 	]' ]] && return 1
  [[ $lower =~ 'bearer [a-z0-9._~+/=-]{20,}' ]] && return 1
  [[ $line =~ 'eyJ[A-Za-z0-9_-]{8,}\.eyJ[A-Za-z0-9_-]{8,}' ]] && return 1
  [[ $line =~ 'sshpass +-p' ]] && return 1
  return 0
}
autoload -Uz add-zsh-hook
add-zsh-hook zshaddhistory _secret_history_filter
