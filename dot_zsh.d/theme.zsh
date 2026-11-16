# Neon Tokyo Night colors for the interactive shell.
# Matches herdr-app/themes/tokyo-neon.json and oh-my-posh/tokyo-neon.omp.toml.
# Sourced after zinit loads zsh-syntax-highlighting / zsh-autosuggestions.

# zsh-autosuggestions: dim slate ghost text
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#565f89'

# zsh-syntax-highlighting
typeset -gA ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[default]='fg=#c0caf5'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#ff4f8b,bold'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#c792ff'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=#c792ff,italic'
ZSH_HIGHLIGHT_STYLES[command]='fg=#2ee6ff'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#2ee6ff'
ZSH_HIGHLIGHT_STYLES[alias]='fg=#2ee6ff'
ZSH_HIGHLIGHT_STYLES[suffix-alias]='fg=#2ee6ff,underline'
ZSH_HIGHLIGHT_STYLES[global-alias]='fg=#2ee6ff'
ZSH_HIGHLIGHT_STYLES[function]='fg=#7aa2ff'
ZSH_HIGHLIGHT_STYLES[hashed-command]='fg=#2ee6ff'
ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=#ff007c'
ZSH_HIGHLIGHT_STYLES[redirection]='fg=#ff007c'
ZSH_HIGHLIGHT_STYLES[named-fd]='fg=#ff007c'
ZSH_HIGHLIGHT_STYLES[path]='fg=#c0caf5,underline'
ZSH_HIGHLIGHT_STYLES[path_prefix]='fg=#c0caf5,underline'
ZSH_HIGHLIGHT_STYLES[autodirectory]='fg=#7df9ff,underline'
ZSH_HIGHLIGHT_STYLES[globbing]='fg=#ffc66d'
ZSH_HIGHLIGHT_STYLES[history-expansion]='fg=#ffc66d'
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#7df9ff'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#7df9ff'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#9ff26a'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#9ff26a'
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=#9ff26a'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=#c792ff'
ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter]='fg=#c792ff'
ZSH_HIGHLIGHT_STYLES[process-substitution-delimiter]='fg=#c792ff'
ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]='fg=#ffc66d'
ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]='fg=#ffc66d'
ZSH_HIGHLIGHT_STYLES[assign]='fg=#c0caf5'
ZSH_HIGHLIGHT_STYLES[arg0]='fg=#2ee6ff'
ZSH_HIGHLIGHT_STYLES[comment]='fg=#565f89,italic'
