#!/bin/zsh

if [ -z "$1" ]; then
  echo "Usage: $0 session-name"
  exit 1
fi

if [ -z "$TMUX" ]; then
  if tmux has-session -t "=$1" 2>/dev/null; then
    exec tmux attach-session -t "$1"
  else
    exec tmux new-session -s "$1"
  fi
else
  if ! tmux has-session -t "=$1" 2>/dev/null; then
    tmux new-session -d -s "$1"
  fi
  exec tmux switch-client -t "$1"
fi
