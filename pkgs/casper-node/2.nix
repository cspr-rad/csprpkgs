{ lib
, rustPlatform
, fetchFromGitHub
, cmake
, pkg-config
, openssl
, removeReferencesTo
, cargo
}:
rustPlatform.buildRustPackage {
  pname = "casper-node";
  version = "2.0.0-rc4";

  src = fetchFromGitHub {
    owner = "casper-network";
    repo = "casper-node";
    # from feat-2.0 branch https://github.com/casper-network/casper-node/tree/release-2.0.0-rc4
    rev = "4e2ddf485e5cec830f9ff402b052f5f55801eb54";
    hash = "sha256-9xn+CDFkI/5OyUOc6L/4KI0W1bLTEjsNqf/f5ybysB8=";
  };

  cargoHash = "sha256-8EwV9n5FbjruG88nl1SKhgmm7wbYoZFQwlMe9K7KWzI=";

  nativeBuildInputs = [ pkg-config cmake removeReferencesTo ];
  buildInputs = [ openssl.dev ];

  doCheck = false;

  postInstall = ''
    find "$out" -type f -exec remove-references-to -t ${cargo} '{}' +
  '';

  meta = with lib; {
    description = "Reference node for the Casper Blockchain Protocol.";
    homepage = "https://casper.network/";
    license = licenses.asl20;
    mainProgram = "casper-node";
  };
}
