# This module owns boot-time behavior so loader, kernel, and Plymouth changes
# are reviewed together instead of being scattered through the host definition.
{ pkgs, ... }:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Keep the handoff graphical: bootloader, Plymouth, then the DMS greeter.
  # Individual hosts add their graphics module to the initrd when required.
  boot.plymouth.enable = true;
  boot.initrd.verbose = false;
  boot.consoleLogLevel = 0;
  boot.kernelParams = [
    "quiet"
    "udev.log_level=3"
    "vt.global_cursor_default=0"
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;
}
