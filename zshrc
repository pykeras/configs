typeset -g POWERLEVEL9K_INSTANT_PROMPT=off

# Auto-start zellij only in a local graphical terminal (not SSH, not a plain tty)
if [[ -z "$SSH_CONNECTION" && -z "$SSH_TTY" ]] && [[ -n "${DISPLAY}${WAYLAND_DISPLAY}" ]]; then
    eval "$(zellij setup --generate-auto-start zsh)"
fi

# POWERLEVEL10K INSTANT PROMPT
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# OH MY ZSH
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(
  git
  k
  zsh-syntax-highlighting
  zsh-autosuggestions
)
fpath=(~/.config/zsh/completions $fpath) # custom completions for just
source "$ZSH/oh-my-zsh.sh"

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

. "$HOME/.local/bin/env"

export PATH="$PATH:/opt/nvim/bin"

# COMPLETIONS
zstyle ':completion:*:*:docker:*' option-stacking yes
zstyle ':completion:*:*:docker-*:*' option-stacking yes

# AUTO PYTHON VENV
python_venv() {
  local MYVENV="./.venv"

  if [[ -d "$MYVENV" ]]; then
    source "$MYVENV/bin/activate" > /dev/null 2>&1
  fi
}

autoload -U add-zsh-hook
add-zsh-hook chpwd python_venv
python_venv

greet

