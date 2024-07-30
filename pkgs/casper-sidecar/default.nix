{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, openssl
, stdenv
, darwin
}:
rustPlatform.buildRustPackage rec {
  pname = "casper-sidecar";
  version = "2.0";

  src = fetchFromGitHub {
    owner = "casper-network";
    repo = "casper-sidecar";
    rev = "feat-${version}";
    hash = "sha256-XVQVS0wqkufnazzgRo1HosnPIkyptl6AeJYQOAWN/O8=";
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
      "casper-binary-port-1.0.0" = "sha256-9FFur8DvRZjup+tjT2+Gr/LCk10qYGwQnsfceOXcbBg=";
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
