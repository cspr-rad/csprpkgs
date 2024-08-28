{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, openssl
, stdenv
, darwin
}:
rustPlatform.buildRustPackage {
  pname = "casper-sidecar";
  version = "1.0.0rc2";

  src = fetchFromGitHub {
    owner = "casper-network";
    repo = "casper-sidecar";
    rev = "release-1.0.0rc2_node-2.0.0rc3";
    hash = "sha256-Dz5Q7+6AkHSD+ut3jIkyulkZGwfAkskE770oZoY8dCg=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [
    openssl.dev
  ] ++ lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.SystemConfiguration
  ];

  doCheck = false; # pg-embed tries to download postgresql binaries when running the tests

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "archiver-rs-0.5.1" = "sha256-ZIik0mMABmhdx/ullgbOrKH5GAtqcOKq5A6vB7aBSjk=";
      "casper-binary-port-1.0.0" = "sha256-V8dRuVw0rgBatPfDpFl4LjzFSfOi0EHa20a7zj7v1+w=";
      "pg-embed-0.7.2" = "sha256-ot0sQg2+KRI6SOC7wKJ2l6Lde0fcwulxoRaxrpr/6z4=";

    };
  };

  meta = with lib; {
    description = "Augments the casper-node's functionality to allow to monitor the event stream, query stored events, and query the JSON RPC API";
    homepage = "https://github.com/casper-network/casper-sidecar";
    license = licenses.asl20;
    mainProgram = "casper-sidecar";
  };
}
