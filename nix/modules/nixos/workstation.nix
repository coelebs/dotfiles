# This is the reusable baseline for an interactive workstation. It collects
# small system-wide defaults while focused modules own complex or independent
# domains such as the desktop, greeter, services, and user account.
{ pkgs, ... }:

{
  imports = [
    ./boot.nix
    ./desktop.nix
    ./greeter.nix
    ./home-manager.nix
    ./omarchy.nix
    ./services.nix
    ./user.nix
  ];

  time.timeZone = "Europe/Amsterdam";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "nl_NL.UTF-8";
    LC_IDENTIFICATION = "nl_NL.UTF-8";
    LC_MEASUREMENT = "nl_NL.UTF-8";
    LC_MONETARY = "nl_NL.UTF-8";
    LC_NAME = "nl_NL.UTF-8";
    LC_NUMERIC = "nl_NL.UTF-8";
    LC_PAPER = "nl_NL.UTF-8";
    LC_TELEPHONE = "nl_NL.UTF-8";
    LC_TIME = "nl_NL.UTF-8";
  };

  networking = {
    nameservers = [ "1.1.1.1" "8.8.8.8" ];
    networkmanager.enable = true;
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  # These NixOS options provide integration beyond installing the applications:
  # Firefox is system-enabled and LocalSend opens its required firewall ports.
  programs.firefox.enable = true;
  programs.localsend = {
    enable = true;
    openFirewall = true;
  };

  # Home Manager owns personal applications. Keep only desktop-wide runtime
  # packages here, including QuickShell for the packaged Omarchy environment.
  environment.systemPackages = with pkgs; [
    adwaita-icon-theme
  ];
}
