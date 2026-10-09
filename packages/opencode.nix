{ autoPatchelfHook, fetchurl, lib, stdenv }:

stdenv.mkDerivation (finalAttrs: {
  pname = "opencode";
  version = "2.0.26";

  src = fetchurl {
    url = "https://registry.npmjs.org/@opencode/cli-linux-x64/-/cli-linux-x64-${finalAttrs.version}.tgz";
    hash = "sha256-ChFuAzoCgEdB1GRDN9ASvfWiSqwzo0wMllNNLVOWERk=";
  };

  sourceRoot = "package";
  nativeBuildInputs = [ autoPatchelfHook ];
  # Stripping Bun's compiled executable removes its embedded application.
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    # The Bun executable must retain its original basename to find its embedded app.
    install -Dm755 bin/opencode "$out/libexec/opencode/opencode"
    mkdir -p "$out/bin"
    cat > "$out/bin/opencode" <<EOF
    #!/bin/sh
    exec "$out/libexec/opencode/opencode" "\$@"
    EOF
    chmod +x "$out/bin/opencode"
    runHook postInstall
  '';

  meta = {
    description = "OpenCode v2 CLI";
    homepage = "https://opencode.ai/v2/docs";
    license = lib.licenses.mit;
    mainProgram = "opencode";
    platforms = [ "x86_64-linux" ];
  };
})
