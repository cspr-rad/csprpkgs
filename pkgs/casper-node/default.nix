{ lib
, rustPlatform
, fetchFromGitHub
, cmake
, pkg-config
, openssl
}:
rustPlatform.buildRustPackage rec {
  pname = "casper-node";
  version = "1.5.6";

  src = fetchFromGitHub {
    owner = "casper-network";
    repo = "casper-node";
    rev = "v${version}";
    sha256 = "sha256-Jm5f8gzX5HYkQMjEI4dV3ooVPyxhpf/lGyryyuAapqI=";
  };

  cargoHash = "sha256-7yQcPsv7rSZUwWPDFrmeKiU/CKaw1l39Z1LmUSiHLSc=";

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
