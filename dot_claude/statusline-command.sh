#!/usr/bin/env bash
# ABOUTME: Claude Code status line script inspired by whegedus's Starship config.
# ABOUTME: Shows directory, git branch/status, model, and context usage.

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
model=$(echo "$input" | jq -r '.model.display_name // ""')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Truncate path: replace $HOME with ~, keep last 3 segments
home="$HOME"
short_path="${cwd/#$home/~}"
IFS='/' read -ra parts <<< "$short_path"
count=${#parts[@]}
if [ "$count" -gt 3 ]; then
  short_path="${parts[$((count-3))]}/${parts[$((count-2))]}/${parts[$((count-1))]}"
  # Preserve leading ~ if it was there and got truncated
fi

# Git info (skip optional locks for performance)
git_branch=""
git_status_str=""
if git_branch_raw=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null); then
  git_branch="$git_branch_raw"
elif git_branch_raw=$(git -C "$cwd" rev-parse --short HEAD 2>/dev/null); then
  git_branch="$git_branch_raw"
fi

if [ -n "$git_branch" ]; then
  git_flags=""
  git_status_out=$(git -C "$cwd" status --porcelain 2>/dev/null)
  if [ -n "$git_status_out" ]; then
    staged=$(echo "$git_status_out" | grep -c '^[MADRC]' || true)
    modified=$(echo "$git_status_out" | grep -c '^.[MD]' || true)
    untracked=$(echo "$git_status_out" | grep -c '^??' || true)
    [ "$staged" -gt 0 ]    && git_flags="${git_flags}+"
    [ "$modified" -gt 0 ]  && git_flags="${git_flags}!"
    [ "$untracked" -gt 0 ] && git_flags="${git_flags}?"
  fi
  # Check ahead/behind
  ahead=$(git -C "$cwd" rev-list --count '@{u}..HEAD' 2>/dev/null || echo 0)
  behind=$(git -C "$cwd" rev-list --count 'HEAD..@{u}' 2>/dev/null || echo 0)
  [ "$ahead" -gt 0 ]  && git_flags="${git_flags}⇡"
  [ "$behind" -gt 0 ] && git_flags="${git_flags}⇣"
  [ -n "$git_flags" ] && git_status_str=" [$git_flags]"
fi

# Context usage bar
ctx_str=""
if [ -n "$used_pct" ]; then
  used_int=${used_pct%.*}
  if [ "$used_int" -ge 75 ]; then
    ctx_str=" ctx:${used_int}%"
  fi
fi

# Compose output with ANSI colors (dimmed-friendly)
printf "\033[1;36m%s\033[0m" "$short_path"

if [ -n "$git_branch" ]; then
  printf " \033[1;35mon %s\033[0m" "$git_branch"
  if [ -n "$git_status_str" ]; then
    printf "\033[1;31m%s\033[0m" "$git_status_str"
  fi
fi

if [ -n "$model" ]; then
  printf " \033[2m| %s\033[0m" "$model"
fi

if [ -n "$ctx_str" ]; then
  printf "\033[33m%s\033[0m" "$ctx_str"
fi

printf "\n"
