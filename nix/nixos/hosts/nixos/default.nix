# This file describes facts unique to the current machine and owner. Keeping
# them here lets the workstation module remain reusable by a future private flake.
{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "nixos";

  dotfiles = {
    primaryUser = "vin";
    primaryUserFullName = "Vincent Kriek";
  };

  # Do not change this after installation without a deliberate data migration.
  system.stateVersion = "26.05";
}
