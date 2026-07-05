# Auto attach or create tmux session 'init' at login
if command -v tmux >/dev/null 2>&1 && [[ -t 0 ]] && [[ -t 1 ]]; then
  # Prevent nesting tmux in a tmux session
  if [ -z "$TMUX" ]; then
    SESSION="init"
    if tmux has-session -t "$SESSION" 2>/dev/null; then
      exec tmux attach-session -t "$SESSION"
    else
      exec tmux new-session -s "$SESSION"
    fi
  fi
fi

