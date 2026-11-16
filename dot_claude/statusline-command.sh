#!/usr/bin/env bash
# Claude Code status line — multi-line, left-aligned
# Line 1: path  git  ctx  rate-bars  cost
# Line 2: model  effort  version

export LC_ALL=${LC_ALL:-en_US.UTF-8}

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
model=$(echo "$input" | jq -r '.model.display_name // ""')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
total_input=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
total_output=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
rate_5h=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
rate_5h_resets=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
rate_7d=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
rate_7d_resets=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')
effort_level=$(echo "$input" | jq -r '.effort.level // empty')
current_version=$(echo "$input" | jq -r '.version // empty')
login_email=$(jq -r '.oauthAccount.emailAddress // empty' "$HOME/.claude.json" 2>/dev/null)

# Auth mode: an active `claude login` (OAuth) session takes priority over
# ANTHROPIC_API_KEY — the env var is only actually used as a fallback when
# there's no logged-in account. Bedrock/Vertex are a separate infra route
# and take priority over both, since OAuth can't be used with them.
auth_mode=""
if [ "$CLAUDE_CODE_USE_BEDROCK" = "1" ]; then
  auth_mode="Bedrock"
elif [ "$CLAUDE_CODE_USE_VERTEX" = "1" ]; then
  auth_mode="Vertex"
elif [ -n "$login_email" ]; then
  seat_tier=$(jq -r '.oauthAccount.seatTier // empty' "$HOME/.claude.json" 2>/dev/null)
  auth_mode="${seat_tier:-subscription}"
elif [ -n "$ANTHROPIC_API_KEY" ]; then
  auth_mode="API key"
fi

# ANSI color codes (dimmed-friendly)
blue='\033[38;2;137;180;250m'     # p:blue  #89b4fa
lavender='\033[38;2;180;190;254m' # p:lavender #b4befe
cyan='\033[38;2;137;220;235m'     # p:sky #89dceb
yellow='\033[38;2;249;226;175m'   # p:yellow #f9e2af
mauve='\033[38;2;203;166;247m'    # p:mauve #cba6f7
green='\033[38;2;166;227;161m'    # p:green #a6e3a1
red='\033[38;2;243;139;168m'      # p:red #f38ba8
peach='\033[38;2;250;179;135m'    # p:peach #fab387
teal='\033[38;2;148;226;213m'     # p:teal  #94e2d5
dim='\033[2m'
reset='\033[0m'

# --- Helper: render a compact progress bar ---
make_bar() {
  local pct=$1
  local width=${2:-8}
  local filled=$(( pct * width / 100 ))
  local empty=$(( width - filled ))
  local bar=""
  local i
  for (( i=0; i<filled; i++ )); do bar="${bar}█"; done
  for (( i=0; i<empty; i++ )); do bar="${bar}░"; done
  printf '%s' "$bar"
}

# --- Color for a percentage value ---
# green < 60%, yellow < 80%, red >= 80%
pct_color() {
  local pct=$1
  if [ "$pct" -ge 80 ] 2>/dev/null; then
    printf '%s' "$red"
  elif [ "$pct" -ge 60 ] 2>/dev/null; then
    printf '%s' "$yellow"
  else
    printf '%s' "$green"
  fi
}

# ============================================================
# LINE 1 segments: path  git  ctx  rate-bars  cost
# ============================================================

# --- Path segment ---
line1="${blue}${cwd}${reset}"

# --- Git segment ---
if git -C "$cwd" rev-parse --git-dir --no-optional-locks > /dev/null 2>&1; then
  branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
  dirty=""
  if ! git -C "$cwd" diff --quiet --no-optional-locks 2>/dev/null || \
     ! git -C "$cwd" diff --cached --quiet --no-optional-locks 2>/dev/null; then
    dirty="*"
  fi
  ahead_behind=$(git -C "$cwd" rev-list --left-right --count HEAD...@{upstream} 2>/dev/null)
  ahead=""
  behind=""
  if [ -n "$ahead_behind" ]; then
    behind_count=$(echo "$ahead_behind" | awk '{print $1}')
    ahead_count=$(echo "$ahead_behind" | awk '{print $2}')
    [ "$behind_count" -gt 0 ] 2>/dev/null && behind="⇣"
    [ "$ahead_count" -gt 0 ] 2>/dev/null && ahead="⇡"
  fi
  line1="${line1}  ${lavender} ${branch}${dirty}${reset}${cyan}${behind}${ahead}${reset}"
fi

# --- Context window progress bar ---
if [ -n "$used_pct" ]; then
  used_int=$(printf '%.0f' "$used_pct")
  bar_color=$(pct_color "$used_int")
  bar=$(make_bar "$used_int" 8)
  line1="${line1}  ${dim}ctx${reset} ${bar_color}${bar}${reset}${dim}${used_int}%${reset}"
fi

# --- Rate limits progress bars ---
if [ -n "$rate_5h" ]; then
  r5_int=$(printf '%.0f' "$rate_5h")
  bar_color=$(pct_color "$r5_int")
  bar=$(make_bar "$r5_int" 6)
  r5_reset=""
  [ -n "$rate_5h_resets" ] && r5_reset=" ${dim}→$(date -r "$rate_5h_resets" +%H:%M)${reset}"
  line1="${line1}  ${dim}5h${reset} ${bar_color}${bar}${reset}${dim}${r5_int}%${reset}${r5_reset}"
fi
if [ -n "$rate_7d" ]; then
  r7_int=$(printf '%.0f' "$rate_7d")
  bar_color=$(pct_color "$r7_int")
  bar=$(make_bar "$r7_int" 6)
  r7_reset=""
  [ -n "$rate_7d_resets" ] && r7_reset=" ${dim}→$(date -r "$rate_7d_resets" "+%a %H:%M")${reset}"
  line1="${line1}  ${dim}7d${reset} ${bar_color}${bar}${reset}${dim}${r7_int}%${reset}${r7_reset}"
fi

# --- Session cost estimate ---
# Pricing: input $3/1M tokens, output $15/1M tokens (Sonnet tier)
if [ "$total_input" -gt 0 ] 2>/dev/null || [ "$total_output" -gt 0 ] 2>/dev/null; then
  cost=$(awk -v inp="$total_input" -v out="$total_output" \
    'BEGIN { printf "%.4f", (inp * 3 / 1000000) + (out * 15 / 1000000) }')
  line1="${line1}  ${peach}~\$${cost}${reset}"
fi

# ============================================================
# LINE 2 segments: model  effort  version
# ============================================================
line2=""

# --- Model segment ---
if [ -n "$model" ]; then
  line2="${mauve}${model}${reset}"
fi

# --- Login email segment ---
if [ -n "$login_email" ]; then
  [ -n "$line2" ] && line2="${line2}  "
  line2="${line2}${dim}${login_email}${reset}"
fi

# --- Auth mode segment ---
if [ -n "$auth_mode" ]; then
  [ -n "$line2" ] && line2="${line2}  "
  if [ "$auth_mode" = "API key" ] || [ "$auth_mode" = "Bedrock" ] || [ "$auth_mode" = "Vertex" ]; then
    line2="${line2}${dim}auth:${reset}${peach}${auth_mode}${reset}"
  else
    line2="${line2}${dim}auth:${reset}${green}${auth_mode}${reset}"
  fi
fi

# --- Effort segment ---
if [ -n "$effort_level" ]; then
  [ -n "$line2" ] && line2="${line2}  "
  line2="${line2}${dim}effort:${reset}${teal}${effort_level}${reset}"
fi

# --- Version segment ---
cache_file="$HOME/.claude/.claude-latest-version"
# Refresh cache in the background if missing or older than 1 hour
if [ ! -f "$cache_file" ] || [ $(( $(date +%s) - $(stat -f %m "$cache_file" 2>/dev/null || echo 0) )) -gt 3600 ]; then
  ( npm view @anthropic-ai/claude-code version 2>/dev/null > "${cache_file}.tmp" && mv "${cache_file}.tmp" "$cache_file" ) &>/dev/null &
fi
latest_version=$(cat "$cache_file" 2>/dev/null | tr -d '[:space:]')
if [ -n "$current_version" ]; then
  [ -n "$line2" ] && line2="${line2}  "
  if [ -n "$latest_version" ]; then
    if [ "$current_version" = "$latest_version" ]; then
      line2="${line2}${dim}v${reset}${green}${current_version}${reset} ${dim}(latest)${reset}"
    else
      line2="${line2}${dim}v${reset}${yellow}${current_version}${reset} ${dim}→${reset} ${green}${latest_version}${reset}"
    fi
  else
    line2="${line2}${dim}v${reset}${green}${current_version}${reset}"
  fi
fi

# ============================================================
# Multi-line left-aligned output
# ============================================================
if [ -n "$line2" ]; then
  printf "%b\n%b\n" "$line1" "$line2"
else
  printf "%b\n" "$line1"
fi
