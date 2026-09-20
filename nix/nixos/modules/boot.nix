# This module owns boot-time behavior so loader, kernel, and Plymouth changes
# are reviewed together instead of being scattered through the host definition.
{ pkgs, ... }:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.consoleMode = "0";
  boot.loader.efi.canTouchEfiVariables = true;

  # Keep the handoff graphical: bootloader, Plymouth, then the DMS greeter.
  # `xe` is ready in the initrd so Plymouth can take over the display early.
  boot.plymouth.enable = true;
  boot.initrd = {
    kernelModules = [ "xe" ];
    verbose = false;
  };
  boot.consoleLogLevel = 0;
  boot.kernelParams = [
    "quiet"
    "udev.log_level=3"
    "vt.global_cursor_default=0"
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;
}
