# Dotfiles

NixOS workstation configuration and personal dotfiles.

The Nix flake lives in `nix/`. NixOS owns hardware, services, and the desktop;
Home Manager owns the active user's packages and these active dotfile targets:

- `~/.alias`, `~/.bash_profile`, and `~/.bashrc`
- `~/.config/nvim`
- `~/.local/bin`
- `~/.tmux.conf`

The source files retain their existing Stow-style layout at the repository
root, but Home Manager deploys them. Do not run Stow for those targets after
the first Home Manager activation.

Apply the configuration with:

```sh
sudo nixos-rebuild switch --flake ~/Projects/dotfiles/nix#nixos
```

On the first activation, existing conflicting Stow links are renamed with the
`before-home-manager` suffix rather than deleted. Verify the new links work,
then remove those backup links manually.

Legacy i3, Sway, mail, and Zsh configurations remain in the repository but are
not enabled or managed by Home Manager yet.
