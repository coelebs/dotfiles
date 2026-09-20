# This module centralizes Nix behavior and package-policy choices for the
# workstation, keeping them separate from the packages actually installed.
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
}
