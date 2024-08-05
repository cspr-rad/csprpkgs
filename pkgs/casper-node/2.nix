{ lib
, rustPlatform
, fetchFromGitHub
, cmake
, pkg-config
, openssl
}:
rustPlatform.buildRustPackage rec {
  pname = "casper-node";
  version = "2.0";

  src = fetchFromGitHub {
    owner = "casper-network";
    repo = "casper-node";
    rev = "feat-${version}";
    hash = "sha256-rk4teBZ42yJVNSRV07Xg10PtA1JsDG59jdNsVegZnzw=";
  };

  cargoHash = "sha256-jyJsFRRCr/K2z4cfqblmWQK2q2TVP+3osWqAzk9S2sQ=";

  nativeBuildInputs = [ pkg-config cmake ];
  buildInputs = [ openssl.dev ];

  doCheck = false;

  meta = with lib; {
    description = "Reference node for the Casper Blockchain Protocol.";
    homepage = "https://casper.network/";
    license = licenses.asl20;
    mainProgram = "casper-node";
  };
}
