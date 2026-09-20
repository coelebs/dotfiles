# This module groups the non-desktop system services required for printing,
# audio, remappable input, removable media, power management, and Bluetooth.
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
  security.pam.services.omarchy-lock-password = { };
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;
  services.udisks2.enable = true;
  hardware.bluetooth.enable = true;
}
