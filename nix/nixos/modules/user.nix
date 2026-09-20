# This module creates the primary interactive account from host-provided owner
# options, allowing the workstation profile to avoid a hardcoded username.
{ config, ... }:

let
  inherit (config.dotfiles) primaryUser primaryUserFullName;
in
{
  users.users.${primaryUser} = {
    isNormalUser = true;
    description = primaryUserFullName;
    home = "/home/${primaryUser}";
    extraGroups = [ "networkmanager" "wheel" ];
  };
}
