{ rustPlatform
, fetchFromGitHub
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
    # from https://github.com/casper-ecosystem/casper-client-rs/tree/feat-track-node-2.0
    rev = "2227d5ada7a02f9406a7fb0cb290e55bea3e30e5";
    sha256 = "sha256-ot6Q3lpPohob/44n6+mj2TOEmzAjsY40L3G8he/hRq4=";
  };

  cargoPatches = [
    ./add-Cargo_2.lock.patch
  ];

  cargoLock = {
    lockFile = ./Cargo_2.lock;
    outputHashes = {
      "casper-types-5.0.0" = "sha256-S/6q/lFZbpwO6hjkpFkUwH/9tBYIIICBzIHgSpgSrKE=";
    };
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    openssl.dev
  ] ++ lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.SystemConfiguration
  ];
}
