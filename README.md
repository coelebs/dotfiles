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

## NixOS switch for Omarchy

The optional `nixosModules."nixos-switch"` exports a POSIX `nixos-switch`
command and the `coelebs.nixos-switch` Omarchy bar widget. Add the module to
the NixOS flake's `modules` list alongside `dotfiles.nixosModules.workstation`,
then configure it in the host module:

```nix
# flake.nix (dotfiles is an input)
modules = [ dotfiles.nixosModules.workstation dotfiles.nixosModules."nixos-switch" ./hosts/nixos ];

# hosts/nixos/default.nix
{
  programs.omarchyNixosSwitch = {
    enable = true;
    machineFlake = "/home/you/Projects/machine";
    dotfilesCheckout = "/home/you/Projects/dotfiles";
    configuration = "nixos"; # optional; defaults to nixos
  };
}
```

The paths are checked **at runtime**: they are your editable checkouts, not
Nix store copies. `nixos-switch` runs `nixos-rebuild switch` against the machine
flake with the dotfiles checkout overriding its `dotfiles` input. From a
terminal it uses `sudo`; without a terminal it uses `pkexec` and notifies you
of the result. While it runs, the widget displays the rebuild status.

Home Manager installs the plugin files and an Omarchy hook, but does not own
`shell.json`. An activation in a running desktop adds the widget immediately;
the post-boot hook handles first installs without a running shell, and the
post-update hook restores it after Omarchy updates. All use `omarchy bar put`,
which leaves user-reordered widgets in place and tolerates changed upstream
neighbors.
