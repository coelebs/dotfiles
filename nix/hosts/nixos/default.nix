# This file describes facts unique to the current machine and owner. Keeping
# them here lets the workstation module remain reusable by a future private flake.
{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "nixos";

  # The Framework's Intel graphics must be ready in the initrd for Plymouth to
  # take over the display early. This is hardware-specific, not a workstation
  # default shared by every host.
  boot.initrd.kernelModules = [ "xe" ];

  dotfiles = {
    primaryUser = "vin";
    primaryUserFullName = "Vincent Kriek";
  };

  # Do not change this after installation without a deliberate data migration.
  system.stateVersion = "26.05";
}
