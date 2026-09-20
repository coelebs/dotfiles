# This module configures DMS Greeter and keeps its root-owned wallpaper cache
# synchronized with the primary user's Omarchy-selected background.
{ config, lib, pkgs, pkgsUnstable, ... }:

let
  primaryUserHome = config.users.users.${config.dotfiles.primaryUser}.home;

  dmsGreeterWallpaperSync = pkgs.writeShellApplication {
    name = "dms-greeter-wallpaper-sync";
    runtimeInputs = [ pkgs.coreutils pkgs.jq ];
    text = ''
      source="${primaryUserHome}/.local/state/omarchy/current/background"
      cache="/var/lib/dms-greeter"
      wallpaper="$cache/omarchy-wallpaper"
      override="$cache/greeter_wallpaper_override.jpg"

      [ -e "$source" ] || exit 0

      mkdir -p "$cache"
      cp --dereference -- "$source" "$wallpaper"
      # DMS Greeter reads this dedicated override before session.json.
      cp --dereference -- "$source" "$override.tmp"
      mv "$override.tmp" "$override"
      if [ -f "$cache/session.json" ]; then
        jq --arg wallpaper "$wallpaper" '
          .wallpaperPath = $wallpaper
          | .wallpaperPathDark = $wallpaper
          | .wallpaperPathLight = $wallpaper
        ' "$cache/session.json" > "$cache/session.json.tmp"
      else
        jq -n --arg wallpaper "$wallpaper" '
          {
            wallpaperPath: $wallpaper,
            wallpaperPathDark: $wallpaper,
            wallpaperPathLight: $wallpaper
          }
        ' > "$cache/session.json.tmp"
      fi
      mv "$cache/session.json.tmp" "$cache/session.json"
      chown dms-greeter:dms-greeter "$wallpaper" "$override" "$cache/session.json"
    '';
  };
in
{
  # The module itself is imported by the flake from the same package source.
  # Stable's module targets the legacy dms-shell program and is disabled there.
  services.displayManager.dms-greeter = {
    enable = true;
    package = pkgsUnstable.dms-greeter;
    compositor.name = "hyprland";
    configFiles = [
      (pkgs.writeText "session.json" (builtins.toJSON {
        wallpaperPath = "";
        wallpaperPathDark = "";
        wallpaperPathLight = "";
      }))
    ];
  };

  # Initialize the cache before the first greeter starts.
  systemd.services.greetd.preStart = lib.mkAfter ''
    ${dmsGreeterWallpaperSync}/bin/dms-greeter-wallpaper-sync
  '';

  # greetd survives logout, so watch for wallpaper changes made during a user
  # session and refresh the root-owned cache without restarting greetd.
  systemd.services.dms-greeter-wallpaper-sync = {
    description = "Sync Omarchy wallpaper to DMS Greeter";
    serviceConfig.Type = "oneshot";
    script = ''
      exec ${dmsGreeterWallpaperSync}/bin/dms-greeter-wallpaper-sync
    '';
  };
  systemd.paths.dms-greeter-wallpaper-sync = {
    wantedBy = [ "multi-user.target" ];
    pathConfig.PathChanged = "${primaryUserHome}/.local/state/omarchy/current/background";
  };
}
