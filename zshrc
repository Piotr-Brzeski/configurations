# Enable prompt string variable expansion
setopt prompt_subst

# VIM Mode
# Fix delete key
bindkey -M vicmd '^[[3~' delete-char
bindkey -M viins '^[[3~' delete-char
# Define prompt colors for the modes
vim_ins_mode="%1~ %# "
vim_cmd_mode="%F{green}%1~ %# %f"
# Initial value
vim_mode=$vim_ins_mode
# Function to update vim mode indicator based on current keymap
function zle-keymap-select {
  case $KEYMAP in
    vicmd) vim_mode=$vim_cmd_mode ;;
    viins) vim_mode=$vim_ins_mode ;;
    *) vim_mode=$vim_ins_mode ;;
  esac
  zle reset-prompt
}
# Catch command line finish to reset mode to insert
function zle-line-finish {
  vim_mode=$vim_ins_mode
  zle reset-prompt
}
# Register functions
zle -N zle-keymap-select
zle -N zle-line-finish
# Reliable way to handle Ctrl-C (SIGINT) so mode resets correctly
function TRAPINT() {
  vim_mode=$vim_ins_mode
  zle && zle reset-prompt
  return $((128 + $1))
}
bindkey -v
# Set the prompt
PROMPT='${vim_mode}'

# Configure history behavior for better sharing and cleanliness
#setopt inc_append_history   # Append commands immediately to the history file
#setopt share_history        # Share the history across shell sessions
setopt hist_ignore_dups     # Remove duplicate commands in history
setopt hist_reduce_blanks   # Remove superfluous blank spaces
setopt hist_verify          # Show the command expanded from history before running
# fzf history search
fzf-history-widget() {
  BUFFER=$(history -n 1 | fzf --tac --height=60% --layout=reverse --border --prompt='History> ' --query "$LBUFFER")
  CURSOR=$#BUFFER
  zle reset-prompt
}
bindkey '^R' fzf-history-widget
zle -N fzf-history-widget
# fzf file finder widget
fzf-file-widget() {
  local selected
  selected=$(find . -type f 2>/dev/null | fzf --height=60% --layout=reverse --border --prompt='Files> ' --query "$LBUFFER")
  if [[ -n $selected ]]; then
    BUFFER+="$selected"
    CURSOR=$#BUFFER
  fi
  zle reset-prompt
}
bindkey '^F' fzf-file-widget
zle -N fzf-file-widget
