# This module configures the graphical desktop: Xwayland support, Hyprland,
# desktop color preference, and required display fonts.
{ pkgs, pkgsUnstable, ... }:

{
  services.xserver.enable = true;
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  programs.hyprland = {
    enable = true;
    withUWSM = true;

    # Omarchy needs Hyprland >= 0.56.2 for `workspace.special_active`.
    # Keep the portal in the same explicit unstable package set to prevent
    # protocol-version skew with the running compositor.
    package = pkgsUnstable.hyprland;
    portalPackage = pkgsUnstable.xdg-desktop-portal-hyprland;
  };

  # GTK applications, including Firefox, use this desktop color preference.
  programs.dconf.profiles.user.databases = [
    {
      settings."org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        gtk-theme = "Adwaita-dark";
      };
    }
  ];

  fonts = {
    packages = with pkgs; [ nerd-fonts.jetbrains-mono ];
    fontconfig.defaultFonts.monospace = [ "JetBrainsMono Nerd Font" ];
  };
}
