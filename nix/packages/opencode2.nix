{ autoPatchelfHook, fetchurl, lib, stdenv }:

stdenv.mkDerivation (finalAttrs: {
  pname = "opencode2";
  version = "2.0.18";

  src = fetchurl {
    url = "https://registry.npmjs.org/@opencode/cli-linux-x64/-/cli-linux-x64-${finalAttrs.version}.tgz";
    hash = "sha256-qkVdBzs6BzOmkS9HezcPPVDKevRHFbt8zEH6oTs8wus=";
  };

  sourceRoot = "package";
  nativeBuildInputs = [ autoPatchelfHook ];
  # Stripping Bun's compiled executable removes its embedded application.
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    # The Bun executable must retain its original basename to find its embedded app.
    install -Dm755 bin/opencode "$out/libexec/opencode2/opencode"
    mkdir -p "$out/bin"
    cat > "$out/bin/opencode2" <<EOF
    #!/bin/sh
    exec "$out/libexec/opencode2/opencode" "\$@"
    EOF
    chmod +x "$out/bin/opencode2"
    runHook postInstall
  '';

  meta = {
    description = "OpenCode v2 CLI, installed alongside OpenCode v1";
    homepage = "https://opencode.ai/v2/docs";
    license = lib.licenses.mit;
    mainProgram = "opencode2";
    platforms = [ "x86_64-linux" ];
  };
})
