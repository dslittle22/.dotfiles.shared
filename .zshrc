export HISTFILE="$ZDOTDIR/.zhistory" # History filepath
export HISTSIZE=1000 # Maximum events for internal history
export SAVEHIST=1000 # Maximum events in history file

# get version control system info
autoload -Uz vcs_info
precmd() { vcs_info }

setopt prompt_subst
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:git*' actionformats "%F{6}%b %F{4}%m%u%c %F{5}(%a)"
# zstyle ':vcs_info:git*' formats "%F{6}%b %F{4}%m%u%c"
PROMPT='%(?..%F{red}?%?)%f%B%F{4}%2~%f %(!.#.→) '
RPROMPT='${vcs_info_msg_0_}'
if [ -n "$VIRTUAL_ENV" ]; then
  PROMPT="🐍:(`basename \"$VIRTUAL_ENV\"`)$PROMPT"
fi

alias python="/opt/homebrew/bin/python3"
alias avenv="source venv/bin/activate"
alias dvenv="deactivate"
alias sz="source ~/.zshrc"
alias vz="vim ~/.zshrc"
alias gs="git status"
alias ga="git add ."
alias gd="git diff"
alias gcm="git commit -m"
alias gcam="git commit -am"

mkcd () {
  mkdir "$1"
  cd "$1"
}

# colorize output of ls, with some aliases
alias ls="ls -G"
alias ll="ls -lG"
alias la="ls -laG"
export CLICOLOR=1
export LSCOLORS=gxfxbEaEBxxEhEhBaDaCaD

source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $(brew --prefix)/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
