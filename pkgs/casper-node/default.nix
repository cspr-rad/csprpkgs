{ lib
, rustPlatform
, fetchFromGitHub
, cmake
, pkg-config
, openssl
}:
rustPlatform.buildRustPackage rec {
  pname = "casper-node";
  version = "1.5.8";

  src = fetchFromGitHub {
    owner = "casper-network";
    repo = "casper-node";
    rev = "release-${version}";
    hash = "sha256-KrWuoYxalEAJylTc3JvBEVb0UqYuUtdogbKVi9rV8Yg=";
  };

  cargoHash = "sha256-PBm4aPXH0oU8Uirbpzei4veiKMVPJeHEZKICEdGcihY=";

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
