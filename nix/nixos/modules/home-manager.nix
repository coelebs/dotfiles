# Home Manager owns the primary user's files and per-user packages. NixOS keeps
# ownership of the account itself, hardware, shared services, and the desktop.
{ config, dotfiles, pkgsUnstable, ... }:

let
  inherit (config.dotfiles) primaryUser;
in
{
  home-manager = {
    # Reuse the package set selected by this NixOS system. This prevents a
    # second nixpkgs evaluation and keeps user packages on the stable release.
    useGlobalPkgs = true;
    useUserPackages = true;

    # Existing Stow links are renamed on the first activation instead of being
    # deleted. Once the migration is verified, these backup links can be removed.
    backupFileExtension = "before-home-manager";

    extraSpecialArgs = {
      inherit pkgsUnstable primaryUser;
      inherit dotfiles;
    };

    users.${primaryUser} = import ../../home/default.nix;
  };
}
