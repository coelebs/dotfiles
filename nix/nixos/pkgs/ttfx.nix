{ lib
, rustPlatform
, fetchFromGitHub
}:

rustPlatform.buildRustPackage {
  pname = "ttfx";
  version = "0.3.2";

  src = fetchFromGitHub {
    owner = "omacom";
    repo = "ttfx";
    rev = "7203e354498462064b7c0a89375051f65cf2ce99";
    hash = "sha256-bwFjC6ZkZibkgXjoYVH2VuqqeXklGR9kmRl2fTitWBU=";
  };

  cargoHash = "sha256-DNrg12MNqBcQi6yvoJObM1gtE90iGBCxeQ3RwueYCE4=";

  meta = {
    description = "Terminal text effects";
    homepage = "https://github.com/omacom/ttfx";
    license = lib.licenses.mit;
    mainProgram = "ttfx";
    platforms = lib.platforms.all;
  };
}
