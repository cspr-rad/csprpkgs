{ rustPlatform
, fetchFromGitHub
, cmake
, pkg-config
, openssl
}:
rustPlatform.buildRustPackage rec {
  pname = "casper-node";
  version = "1.5.4";

  src = fetchFromGitHub {
    owner = "casper-network";
    repo = "casper-node";
    rev = "v${version}";
    sha256 = "sha256-Sr92fOFdso4XFMEDLkDj0BsvSt4oa+MDe1/XckiqqXk=";
  };

  cargoHash = "sha256-uzE7kALID9uzoY9srPBvVxy+rWRbL3pNbJApwLg4Sio=";

  nativeBuildInputs = [ pkg-config cmake ];
  buildInputs = [ openssl.dev ];

  doCheck = false;
}
