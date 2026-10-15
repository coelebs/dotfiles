{ fetchurl, lib, stdenv }:

stdenv.mkDerivation (finalAttrs: {
  pname = "t3code";
  version = "0.0.46-nightly.20261014.3105";

  src = fetchurl {
    url = "https://github.com/pingdotgg/t3code/releases/download/v${finalAttrs.version}/t3-${finalAttrs.version}-linux-x64.tar.gz";
    hash = "sha256-YlHPvrItNoe5TPZW2N1keKNwqKgTCktDu4p7k4dlz+U=";
  };

  dontUnpack = true;
  # The executable contains its Bun runtime and application payload.
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/libexec/t3code" "$out/bin"
    tar -xzf "$src" --strip-components=1 -C "$out/libexec/t3code"
    ln -s "$out/libexec/t3code/t3" "$out/bin/t3"
    cat > "$out/bin/t3code-desktop" <<EOF
    #!/bin/sh
    exec "$out/libexec/t3code/t3" "\$@"
    EOF
    chmod +x "$out/bin/t3code-desktop"
    runHook postInstall
  '';

  meta = {
    description = "T3 Code nightly CLI and desktop server";
    homepage = "https://t3.codes";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "t3";
  };
})
