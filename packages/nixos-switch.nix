# The reusable application: a POSIX CLI and its matching Omarchy bar widget.
# Neither half contains a machine-specific checkout path.
{ lib, stdenvNoCC, shellcheck }:

stdenvNoCC.mkDerivation {
  pname = "nixos-switch";
  version = "1.0.0";
  src = ./nixos-switch;
  nativeBuildInputs = [ shellcheck ];
  doCheck = true;

  checkPhase = ''
    shellcheck --shell=sh nixos-switch ensure-widget
  '';

  installPhase = ''
    install -Dm755 nixos-switch "$out/bin/nixos-switch"
    install -Dm755 ensure-widget "$out/libexec/nixos-switch/ensure-widget"
    install -Dm644 plugin/manifest.json "$out/share/omarchy/plugins/coelebs.nixos-switch/manifest.json"
    install -Dm644 plugin/Widget.qml "$out/share/omarchy/plugins/coelebs.nixos-switch/Widget.qml"
  '';

  meta = {
    description = "Rebuild a live NixOS flake with Omarchy bar progress indicator";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "nixos-switch";
  };
}
