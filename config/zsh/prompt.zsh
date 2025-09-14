# ZSH Prompt Configuration
# Modern, informative prompt with git integration

# Enable prompt substitution
setopt PROMPT_SUBST

# Colors for prompt elements
autoload -U colors && colors

# Git prompt function
git_prompt_info() {
    local branch
    if branch=$(git symbolic-ref --short HEAD 2>/dev/null); then
        local status=""
        local color="%{$fg[green]%}"
        
        # Check for uncommitted changes
        if ! git diff --quiet 2>/dev/null; then
            color="%{$fg[yellow]%}"
            status="${status}*"
        fi
        
        # Check for staged changes
        if ! git diff --cached --quiet 2>/dev/null; then
            color="%{$fg[yellow]%}"
            status="${status}+"
        fi
        
        # Check for untracked files
        if [[ -n $(git ls-files --others --exclude-standard 2>/dev/null) ]]; then
            color="%{$fg[red]%}"
            status="${status}?"
        fi
        
        echo " ${color}(${branch}${status})%{$reset_color%}"
    fi
}

# Directory shortener function
short_pwd() {
    local pwd_length=40
    local pwd_symbol="..."
    
    if [[ ${#PWD} -gt $pwd_length ]]; then
        echo "${pwd_symbol}${PWD: -$((pwd_length - ${#pwd_symbol}))}"
    else
        echo "${PWD/#$HOME/~}"
    fi
}

# Main prompt components
PROMPT_USER="%{$fg[cyan]%}%n%{$reset_color%}"
PROMPT_HOST="%{$fg[blue]%}%m%{$reset_color%}"  
PROMPT_PATH="%{$fg[green]%}\$(short_pwd)%{$reset_color%}"
PROMPT_GIT="\$(git_prompt_info)"
PROMPT_SYMBOL="%{$fg[magenta]%}❯%{$reset_color%}"

# Assemble the prompt
PROMPT="${PROMPT_USER}@${PROMPT_HOST} ${PROMPT_PATH}${PROMPT_GIT} ${PROMPT_SYMBOL} "

# Right-side prompt with timestamp
RPROMPT="%{$fg[black]%}[%*]%{$reset_color%}"

# Continuation prompt for multi-line commands
PROMPT2="%{$fg[magenta]%}❯❯%{$reset_color%} "