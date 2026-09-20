{ lib
, stdenvNoCC
, makeWrapper
, bash
, coreutils
, findutils
, gnugrep
, gnused
, gawk
, glib
, gtk3
, gum
, jq
, util-linux
, procps
, systemd
, quickshell
, qt6Packages
, hyprland
, uwsm
, inotify-tools
, fontconfig
, perl
, wl-clipboard
, writeText
, callPackage
, src
}:

let
  ttfx = callPackage ./ttfx.nix { };
  qtImageFormatsPath = "${qt6Packages.qtimageformats}/lib/qt-6/plugins";
  runtimePath = lib.makeBinPath [ bash coreutils findutils gnugrep gnused gawk glib gtk3 gum jq util-linux procps systemd quickshell qt6Packages.qtimageformats hyprland uwsm inotify-tools fontconfig perl wl-clipboard ttfx ];
  nixAutostart = writeText "autostart.lua" ''
    hl.on("hyprland.start", function()
      hl.exec_cmd("systemctl --user import-environment $(env | cut -d'=' -f 1)")
      hl.exec_cmd("dbus-update-activation-environment --systemd --all")
      hl.exec_cmd("QT_PLUGIN_PATH=${qtImageFormatsPath}:$QT_PLUGIN_PATH omarchy-launch-shell")
      hl.exec_cmd(o.launch("udiskie --automount --no-notify --no-tray"))
    end)
  '';
  legacyNixAutostart = writeText "legacy-autostart.lua" ''
    hl.on("hyprland.start", function()
      hl.exec_cmd("systemctl --user import-environment $(env | cut -d'=' -f 1)")
      hl.exec_cmd("dbus-update-activation-environment --systemd --all")
      hl.exec_cmd("omarchy-launch-shell")
      hl.exec_cmd(o.launch("udiskie --automount --no-notify --no-tray"))
    end)
  '';
in
stdenvNoCC.mkDerivation {
  pname = "omarchy-shell";
  version = lib.removeSuffix "\n" (builtins.readFile "${src}/version");
  inherit src;
  patches = [
    ./patches/browser-policy-nixos.patch
    ./patches/ghostty-live-reload.patch
    ./patches/launch-browser-xdg.patch
    ./patches/theme-staging-swap.patch
  ];
  nativeBuildInputs = [ makeWrapper ];
  installPhase = ''
    install -d "$out/share/omarchy" "$out/bin" "$out/libexec/omarchy"
    ln -s ${ttfx}/bin/ttfx "$out/bin/ttfx"
    cp -R bin config default install shell themes applications "$out/share/omarchy/"
    install -Dm644 ${./omanixy-screensaver.txt} "$out/share/omarchy/nix/omanixy-screensaver.txt"
    cp logo.txt logo.svg icon.txt icon.png version "$out/share/omarchy/"
    chmod -R u+w "$out/share/omarchy"
    install -Dm644 ${nixAutostart} "$out/share/omarchy/default/hypr/autostart.lua"
    patchShebangs "$out/share/omarchy/bin" "$out/share/omarchy/shell"
    substituteInPlace "$out/share/omarchy/config/hypr/hyprland.lua" --replace-fail '/usr/share/omarchy' "$out/share/omarchy"
    substituteInPlace "$out/share/omarchy/default/hypr/paths.lua" --replace-fail '/usr/share/omarchy' "$out/share/omarchy"
    substituteInPlace "$out/share/omarchy/shell/services/AppLibrary.qml" \
      --replace-fail 'uwsm-app -- gtk-launch ' 'uwsm-app -- ${gtk3}/bin/gtk-launch '
    substituteInPlace "$out/share/omarchy/shell/plugins/menu/BarWidget.qml" \
      --replace-fail 'text: "\ue900"' 'text: "\uf313"' \
      --replace-fail 'fontFamily: "omarchy"' 'fontFamily: "JetBrainsMono Nerd Font"'
    while IFS= read -r command; do
      command_name="$(basename "$command")"
      mv "$command" "$out/libexec/omarchy/$command_name"
      makeWrapper "$out/libexec/omarchy/$command_name" "$out/bin/$command_name" --set-default OMARCHY_PATH "$out/share/omarchy" --prefix PATH : ${lib.escapeShellArg runtimePath}
    done < <(find "$out/share/omarchy/bin" -maxdepth 1 -type f -executable -name 'omarchy-*' -print)
    substitute ${./omarchy-nix-init} "$out/bin/omarchy-nix-init" --replace-fail '@omarchyPath@' "$out/share/omarchy" --replace-fail '@legacyNixAutostart@' '${legacyNixAutostart}'
    chmod +x "$out/bin/omarchy-nix-init"
    patchShebangs "$out/bin/omarchy-nix-init"
    wrapProgram "$out/bin/omarchy-nix-init" --set-default OMARCHY_PATH "$out/share/omarchy" --prefix PATH : ${lib.escapeShellArg runtimePath}
  '';
  meta = {
    description = "Omarchy Hyprland and Quickshell desktop runtime for NixOS";
    homepage = "https://omarchy.org";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "omarchy-nix-init";
  };
}
