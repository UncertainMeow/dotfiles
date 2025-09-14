# ZSH History Configuration
# Configured for XDG Base Directory Specification compliance

# History file location (XDG compliant)
export HISTFILE="$XDG_STATE_HOME/zsh/history"

# Create history directory if it doesn't exist
[[ ! -d "$XDG_STATE_HOME/zsh" ]] && mkdir -p "$XDG_STATE_HOME/zsh"

# History settings
export HISTSIZE=50000         # Number of lines kept in session memory
export SAVEHIST=50000         # Number of lines saved to history file

# History options
setopt EXTENDED_HISTORY       # Record timestamp of command in history
setopt HIST_EXPIRE_DUPS_FIRST # Delete duplicates first when history fills up
setopt HIST_IGNORE_DUPS       # Don't record entry if it's a duplicate of previous
setopt HIST_IGNORE_ALL_DUPS   # Delete old record if new is duplicate
setopt HIST_FIND_NO_DUPS      # Don't display duplicates during search
setopt HIST_IGNORE_SPACE      # Don't record entries starting with space
setopt HIST_SAVE_NO_DUPS      # Don't write duplicates to history file
setopt HIST_REDUCE_BLANKS     # Remove extra blanks from commands before recording
setopt HIST_VERIFY            # Show command before executing from history
setopt INC_APPEND_HISTORY     # Write to history file immediately, not when shell exits
setopt SHARE_HISTORY          # Share history between all sessions