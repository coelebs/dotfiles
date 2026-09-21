# This module contains only packages needed system-wide. Per-user command-line
# tools and applications are selected by Home Manager in nix/home/default.nix.
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    adwaita-icon-theme
    quickshell
  ];
}
