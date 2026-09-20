# Only configure interactive Bash sessions.
[[ $- == *i* ]] || return

# Load NixOS's system Bash initialization, including bash-completion.
if [[ -r /etc/bashrc ]]; then
  . /etc/bashrc
fi

export HISTSIZE=2000
export HISTFILE="$HOME/.bash_history"
export HISTCONTROL=ignoredups:erasedups
export EDITOR="nvim"
export CMAKE_EXPORT_COMPILE_COMMANDS=ON
export PATH="$HOME/.local/bin:$PATH"

if [[ -f "$HOME/.alias" ]]; then
  . "$HOME/.alias"
fi

# Match Oh My Zsh's fzf plugin when fzf is available.
if command -v fzf >/dev/null 2>&1; then
  eval "$(fzf --bash)"
fi

# Let man use less's terminal colors, like Oh My Zsh's colored-man-pages plugin.
export LESS_TERMCAP_mb=$'\e[1;31m'
export LESS_TERMCAP_md=$'\e[1;36m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[1;44;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;32m'

bind '"\C-f":"tmux-sessionizer\n"'

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init bash)"
fi
