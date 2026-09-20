# Login shells should load the interactive configuration as well.
if [[ -f "$HOME/.bashrc" ]]; then
  . "$HOME/.bashrc"
fi
