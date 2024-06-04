{ rustPlatform
, fetchFromGitHub
, lib
, pkg-config
, openssl
, stdenv
, darwin
, writeShellScriptBin
}:
let
  git-mock = writeShellScriptBin "git" ''
    echo "got ya"
  '';
in
rustPlatform.buildRustPackage rec {
  pname = "casper-client-rs";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "casper-ecosystem";
    repo = pname;
    rev = "6b61f160a536fafbfb541b1ecb20d05a8e666fd3";
    sha256 = "sha256-faLzUuyqz8lYRGqWa9KVVEYU8wQyr17tROiz98EyQ2g=";
  };

  cargoPatches = [
    ./add-Cargo.lock.patch
  ];

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "casper-hashing-3.0.0" = "sha256-cknUJr2jgIi1974mt1tyE+2ayMd1c+azMabrdWar8yY=";
    };
  };

  nativeBuildInputs = [ pkg-config git-mock ];

  buildInputs = [
    openssl.dev
  ] ++ lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.SystemConfiguration
  ];
}
