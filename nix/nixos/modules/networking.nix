# This module contains network-wide defaults. Machine naming stays in the host
# file because it is an identity-specific fact rather than a workstation default.
{
  networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];
  networking.networkmanager.enable = true;
}
