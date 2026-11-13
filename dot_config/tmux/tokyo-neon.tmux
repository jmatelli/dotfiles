# Neon Tokyo Night for tmux, matching the zsh prompt
# (oh-my-posh/tokyo-neon.omp.toml) and Herdr (herdr-app/themes/tokyo-neon.json):
# rounded pills on a transparent bar, dark text on neon fills.
#
#   ( 󰆍 Yaarz )  1 app   2 n:front  ( 3 git 󰍉 )  4 ai        ( 󰒋 host )( 󰅐 23:30 )
#
# The session pill shows the mode, replacing tmux-mode-indicator:
# cyan = normal, pink + keyboard = prefix pressed, amber = copy mode,
# purple = panes synchronized.

# Mode color/icon, reused by the session pill below.
set -g @neon_mode_color "#{?client_prefix,#ff007c,#{?pane_in_mode,#ffc66d,#{?pane_synchronized,#c792ff,#2ee6ff}}}"
set -g @neon_mode_icon "#{?client_prefix,\U000F030C,#{?pane_in_mode,\U000F018F,\U000F018D}}"

set -g status on
set -g status-justify left
set -g status-style "bg=default,fg=#c0caf5"
set -g status-left-length 60
set -g status-right-length 80

set -g status-left "#[fg=#{E:@neon_mode_color},bg=default]#[fg=#0d0e16,bg=#{E:@neon_mode_color},bold] #{E:@neon_mode_icon} #S #[fg=#{E:@neon_mode_color},bg=default,nobold] "
set -g status-right "#[fg=#c792ff,bg=default]#[fg=#0d0e16,bg=#c792ff] \U000F048B #h #[fg=#c792ff,bg=default] #[fg=#2a2f4d,bg=default]#[fg=#c0caf5,bg=#2a2f4d] \U000F0150 %H:%M #[fg=#2a2f4d,bg=default]"

# Windows: dim text, the current one is a blue pill (like the prompt's folder).
# A magnifying glass marks a zoomed pane.
set -g window-status-separator ""
# Explicit, so a reload also clears backgrounds left by a previous theme.
set -g window-status-style "fg=#565f89,bg=default"
set -g window-status-current-style "bg=default"
set -g window-status-last-style "bg=default"
set -g status-left-style "bg=default"
set -g status-right-style "bg=default"
set -g window-status-format "#[fg=#565f89,bg=default]  #I #W#{?window_zoomed_flag, \U000F0349,}  "
set -g window-status-current-format "#[fg=#7aa2ff,bg=default]#[fg=#0d0e16,bg=#7aa2ff,bold] #I #W#{?window_zoomed_flag, \U000F0349,} #[fg=#7aa2ff,bg=default,nobold]"
set -g window-status-activity-style "fg=#ffc66d,bold"
set -g window-status-bell-style "fg=#ff007c,bold"

# Panes: neon pink for the active one, like Herdr's focused pane.
set -g pane-border-style "fg=#2a2e48"
set -g pane-active-border-style "fg=#ff007c"
set -g display-panes-colour "#565f89"
set -g display-panes-active-colour "#ff007c"

# Prompts, menus, popups, copy mode
set -g message-style "fg=#0d0e16,bg=#2ee6ff,bold"
set -g message-command-style "fg=#0d0e16,bg=#ff007c,bold"
set -g mode-style "fg=#e6ecff,bg=#2e3c64"
set -g copy-mode-match-style "fg=#0d0e16,bg=#ffc66d"
set -g copy-mode-current-match-style "fg=#0d0e16,bg=#ff007c"
set -g menu-style "fg=#c0caf5,bg=#1a1b2b"
set -g menu-selected-style "fg=#0d0e16,bg=#2ee6ff"
set -g menu-border-style "fg=#2a2e48"
set -g popup-border-style "fg=#ff007c"
set -g clock-mode-colour "#2ee6ff"
