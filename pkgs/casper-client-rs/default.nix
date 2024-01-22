{ rustPlatform
, fetchFromGitHub
, makeWrapper
, casper-node
, lib
, pkg-config
, openssl
, stdenv
, darwin
}:
rustPlatform.buildRustPackage rec {
  pname = "casper-client-rs";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "casper-ecosystem";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-QIU4KgjWs7Qr5u90yrSrFTX8CmluxWWRWKbwqHnWI18=";
  };

  cargoPatches = [
    ./add-Cargo.lock.patch
  ];

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "casper-hashing-2.0.0" = "sha256-9BEPnvo3UK21CU68z9nkgT0ye6xSPf3/MazbWieU7v8=";
    };
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    openssl.dev
  ] ++ lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.SystemConfiguration
  ];
}
