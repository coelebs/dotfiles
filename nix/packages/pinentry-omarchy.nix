# pinentry-omarchy — builds the Assuan pinentry and Omarchy shell plugin from
# the coelebs/pinentry-omarchy repository. The flake input carries the plugin
# source; this package only stages files and wraps the launcher's PATH.
{ lib
, stdenvNoCC
, makeWrapper
, bash
, coreutils
, jq
, omarchyShell
  # The pinentry-omarchy checkout (flake input `pinentry-omarchy`).
, src
}:

let
  manifest = builtins.fromJSON (builtins.readFile (builtins.path {
    path = src + "/manifest.json";
    name = "pinentry-omarchy-manifest";
  }));
in
stdenvNoCC.mkDerivation {
  pname = "pinentry-omarchy";
  version = manifest.version;
  dontUnpack = true;
  nativeBuildInputs = [ makeWrapper ];

  # The package keeps the plugin installed under its manifest id so home
  # manager and omarchy-shell resolve both from one build.
  installPhase = ''
    install -Dm755 ${src}/bin/pinentry-omarchy "$out/bin/.pinentry-omarchy-unwrapped"
    install -Dm755 ${src}/bin/pinentry-omarchy-reply "$out/bin/pinentry-omarchy-reply"
    makeWrapper "$out/bin/.pinentry-omarchy-unwrapped" "$out/bin/pinentry-omarchy" \
      --prefix PATH : ${lib.escapeShellArg (lib.makeBinPath [ bash coreutils jq omarchyShell ])}
    install -Dm644 ${src}/manifest.json "$out/share/omarchy/plugins/coelebs.pinentry/manifest.json"
    install -Dm644 ${src}/Panel.qml "$out/share/omarchy/plugins/coelebs.pinentry/Panel.qml"
  '';
}
