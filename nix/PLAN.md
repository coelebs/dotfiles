# NixOS Flake And Omarchy Shell Plan

## Goal

Move the existing channel-based NixOS configuration in `nix/nixos/` to a flake while preserving current behavior. Replace the modified Omarchy checkout with an upstream-pinned Omarchy source input and a downstream Nix package that supplies only the Omarchy shell runtime.

Do not introduce Home Manager.

## Non-goals

- Do not replace the DMS greeter in this migration.
- Do not change bootloader, disk, Hyprland, portal, or login behavior.
- Do not make Arch package management, Omarchy updates, migrations, installers, Direct Boot, or factory reset work.
- Do not copy mutable system files into `/usr/share`; Nix packages expose immutable data through `/nix/store/.../share/omarchy` and the system profile at `/run/current-system/sw/share/omarchy`.

## Current Baseline

- Source configuration: `~/Projects/dotfiles/nix/nixos/`
- Active configuration: `/etc/nixos` resolves to that directory.
- Configuration is channel-based: `<nixpkgs-unstable>` provides Hyprland, the Hyprland portal, DMS greeter, and OpenCode.
- Local Omarchy package: `/home/vin/Projects/omarchy/default.nix`
- Existing NixOS services already cover the desired bar features: NetworkManager, BlueZ, UPower, power-profiles-daemon, PipeWire/WirePlumber, Polkit, UDisks, and Hyprland/UWSM.

## Flake Layout

Create:

```text
nix/
  flake.nix
  flake.lock
  nixos/
    configuration.nix
    hardware-configuration.nix
    modules/
      omarchy-shell.nix
    pkgs/
      omarchy-shell.nix
```

Keep `configuration.nix` and `hardware-configuration.nix` in their current location to preserve the existing `/etc/nixos` symlink layout.

## Step 1: Create A Behavior-Preserving Flake

Add inputs for stable Nixpkgs, unstable Nixpkgs, `nixos-hardware`, and `github:omacom/omarchy` with `flake = false`.

Define `nixosConfigurations.nixos`, matching the configured hostname. Pass inputs through `specialArgs` and replace the implicit `<nixpkgs-unstable>` and `<nixos-hardware/...>` imports with explicit flake input paths.

Retain the existing unstable package set and all current options unchanged, including the DMS greeter module and the unstable Hyprland and portal pairing.

## Step 2: Validate Before Switching

Build the flake before changing the running system:

```bash
sudo nixos-rebuild build --flake ~/Projects/dotfiles/nix#nixos
```

Confirm the resulting closure contains the current DMS greeter, unstable Hyprland and portal, existing boot configuration, services, and packages. Only after a successful build, switch using the flake. Keep the previous boot generation as a rollback option.

## Step 3: Move The Omarchy Package Out Of The Checkout

Create `nix/nixos/pkgs/omarchy-shell.nix`. It will accept the Omarchy source from the flake input and construct a package that installs the shell runtime data:

```text
$out/share/omarchy/
  applications/
  bin/
  config/
  default/
  shell/
  themes/
```

Expose the selected `omarchy-*` commands in `$out/bin` and set:

```nix
environment.sessionVariables.OMARCHY_PATH = "${pkgs.omarchy-shell}/share/omarchy";
```

This makes the running shell use immutable package data directly rather than the current system-profile indirection. Keep `environment.pathsToLink = [ "/share/omarchy" ];` only if it remains useful for inspection or compatibility.

## Step 4: Keep Mutable User Configuration Separate

Without Home Manager, retain editable files under `~/.config` and initialize them deliberately. The package should include `omarchy-nix-init` as a user-invoked helper that copies, without overwriting by default:

- Hyprland configuration
- `~/.config/omarchy/shell.json`
- terminal configuration
- branding files
- the menu extension directory

Do not add a NixOS activation script that writes into `/home/vin`. This keeps NixOS system state and user-owned configuration separate until Home Manager is adopted.

## Step 5: Keep Only The Required Runtime Surface

The downstream package supplies the shell host, themes, bar widgets, menu, notifications, and selected command helpers.

Keep dependencies needed by retained features:

- Quickshell
- Hyprland and UWSM
- Qt image formats
- fonts and fontconfig
- `brightnessctl`
- `pamixer`
- `hyprpicker`
- screenshot dependencies, if capture is retained
- `ttfx`, if the screensaver retains text effects

Do not add pacman, AUR helpers, bootloader tooling, Omarchy installers, or updater dependencies merely to satisfy unused menu actions.

Use the menu overlay to hide `install`, `remove`, `update`, `setup.direct-boot`, and any other explicitly unsupported Arch lifecycle action. Remove `omarchy.system-update` from the bar layout.

## Step 6: Classify Existing Omarchy Checkout Changes

Move or eliminate each local change before deleting the local package integration:

- Move `default.nix`, `nix/omarchy-nix-init`, `nix/ttfx.nix`, and Nix branding into dotfiles.
- Generate the Nix autostart override from the downstream package or module.
- Carry browser XDG desktop-entry discovery as a downstream patch initially, then propose it upstream.
- Carry theme writable staging as a downstream patch initially, then propose it upstream.
- Evaluate monitor-scale persistence as an upstream Omarchy fix rather than Nix-specific behavior.
- Move the custom menu button glyph and screensaver branding to user configuration or a small personal plugin, not a source patch.

After the flake package works, remove `omarchyDesktop = pkgs.callPackage /home/vin/Projects/omarchy/default.nix ...` from `configuration.nix`.

## Step 7: Upstream Tracking Workflow

Use the flake lockfile to update Omarchy:

```bash
nix flake update omarchy
sudo nixos-rebuild build --flake ~/Projects/dotfiles/nix#nixos
```

Review the Omarchy input diff and build result before switching. The Omarchy checkout remains useful for exploration or upstream contributions, but it is no longer required to run the desktop.
