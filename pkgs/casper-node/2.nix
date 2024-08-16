{ lib
, rustPlatform
, fetchFromGitHub
, cmake
, pkg-config
, openssl
}:
rustPlatform.buildRustPackage {
  pname = "casper-node";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "casper-network";
    repo = "casper-node";
    # from feat-2.0 branch https://github.com/casper-network/casper-node/tree/feat-2.0
    rev = "6416c7252b5d8bcd2e48b92d28c43f1d6d917015";
    hash = "sha256-qf7Wz452af77Fww4j20kowY+Prf8Z9EjZaJwN9aW9Dc=";
  };

  cargoHash = "sha256-+fx2HpeTtZdMkdMAz/8gWHByo1nHzW1nhefzULhtqAU=";

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
