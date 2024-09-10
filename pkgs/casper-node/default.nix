{ lib
, rustPlatform
, fetchFromGitHub
, cmake
, pkg-config
, openssl
, removeReferencesTo
, cargo
}:
rustPlatform.buildRustPackage rec {
  pname = "casper-node";
  version = "1.5.7";

  src = fetchFromGitHub {
    owner = "casper-network";
    repo = "casper-node";
    rev = "release-${version}";
    hash = "sha256-4il4mGHQNWfUvN6siej9DTzGTJF5l+O1a9nwbHlB3Q8=";
  };

  cargoHash = "sha256-AbxeP9GRH8lQsHwYiErh/SaAqu1dvTcwaasL0v7xCoU=";

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
