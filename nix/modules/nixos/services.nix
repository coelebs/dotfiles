# This module groups the non-desktop system services required for printing,
# audio, remappable input, removable media, power management, and Bluetooth.
{ config, lib, pkgs, ... }:

let
  # Our Nix-built helper (not Omarchy's Arch /usr/bin command) reads the
  # kernel lid state. pam_exec uses its exit status in both PAM stacks.
  lidClosed = pkgs.callPackage ../../packages/lid-closed.nix { };
  fingerprintPamServices = [
    "sudo" "polkit-1" "login" "greetd" "dms-greeter"
    "swaylock"
  ];
in
{
  services.printing.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = [ "*" ];
      settings.main.capslock = "overload(control, esc)";
    };
  };

  # Omarchy's shell and lock screen rely on these desktop-wide services.
  security.polkit.enable = true;
  # In PAM's extended control syntax, success=1 advances past exactly one
  # following rule. Since this is ordered directly before pam_fprintd, a
  # closed lid bypasses the scan and continues to pam_unix for a password.
  security.pam.services = (lib.genAttrs fingerprintPamServices (name: {
    rules.auth.lidClosed = {
      enable = config.security.pam.services.${name}.fprintAuth;
      order = config.security.pam.services.${name}.rules.auth.fprintd.order - 1;
      control = "[success=1 default=ignore]";
      modulePath = "${config.security.pam.package}/lib/security/pam_exec.so";
      args = [ "quiet" "${lidClosed}" ];
    };
  })) // {
    # The shell runs password and fingerprint PAM contexts independently. Never
    # make a submitted password wait for a fingerprint scan to time out.
    omarchy-lock-password.fprintAuth = false;

    # Unlike the normal PAM stacks, this service has no password fallback. A
    # closed lid must FAIL authentication, not skip its sole fingerprint rule.
    omarchy-lock-fingerprint = lib.mkIf config.services.fprintd.enable {
      useDefaultRules = false;
      rules = {
        auth = {
          lidOpen = {
            order = 100;
            control = "requisite";
            modulePath = "${config.security.pam.package}/lib/security/pam_exec.so";
            args = [ "quiet" "${lidClosed}" "--require-open" ];
          };
          fprintd = {
            order = 200;
            control = "required";
            modulePath = "${config.services.fprintd.package}/lib/security/pam_fprintd.so";
          };
        };
        account.unix = {
          order = 100;
          control = "required";
          modulePath = "${config.security.pam.package}/lib/security/pam_unix.so";
        };
      };
    };
  };
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;
  # Hyprland routes XF86PowerOff to Omarchy's system/power menu.
  services.logind.settings.Login.HandlePowerKey = "ignore";
  services.udisks2.enable = true;
  hardware.bluetooth.enable = true;
}
