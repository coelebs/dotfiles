# This module defines the owner-specific interface and creates the primary
# account, allowing a host to supply identity without hardcoding it elsewhere.
{ config, lib, pkgs, ... }:

let
  inherit (config.dotfiles) primaryUser primaryUserFullName;
in
{
  options.dotfiles = {
    primaryUser = lib.mkOption {
      type = lib.types.str;
      description = "Name of the primary workstation user.";
    };

    primaryUserFullName = lib.mkOption {
      type = lib.types.str;
      description = "Display name of the primary workstation user.";
    };
  };

  config.users.users.${primaryUser} = {
    isNormalUser = true;
    description = primaryUserFullName;
    home = "/home/${primaryUser}";
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" ];
  };

  # NixOS initializes the profile paths used by the account's login shell.
  config.programs.zsh.enable = true;
}
