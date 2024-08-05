{ rustPlatform
, fetchFromGitHub
}:
rustPlatform.buildRustPackage rec {
  pname = "casper-node-launcher";
  version = "1.0.4";

  src = fetchFromGitHub {
    owner = "casper-network";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-KDdeLLeRJKoxxPTs4PnhjyjxI+Xffl/AszSzQbx55+E=";
  };

  cargoHash = "sha256-19iOBjy3U+zY5kM7GOX1Thq8+gh+ohMoYc0+ALGIzGA=";

  doCheck = false;
}
