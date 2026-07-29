# Prompt (starship) + smart cd (zoxide)
export VIRTUAL_ENV_DISABLE_PROMPT=1   # keep venv out of the prompt; starship shows it

command -v zoxide  >/dev/null 2>&1 && eval "$(zoxide init zsh)"   # adds `z <dir>` smart cd
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"
