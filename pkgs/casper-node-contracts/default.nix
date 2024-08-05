{ makeRustPlatform
, fetchFromGitHub
, rust-bin
}:
let
  rust-wasm32 = rust-bin.nightly.latest.default.override {
    targets = [
      "wasm32-unknown-unknown"
    ];
  };
in
(makeRustPlatform {
  cargo = rust-wasm32;
  rustc = rust-wasm32;
}).buildRustPackage rec {
  pname = "casper-node-contracts";
  version = "1.5.7";

  src = fetchFromGitHub {
    owner = "casper-network";
    repo = "casper-node";
    rev = "release-${version}";
    hash = "sha256-4il4mGHQNWfUvN6siej9DTzGTJF5l+O1a9nwbHlB3Q8=";
  };


  cargoHash = "sha256-aK3AFeDey53EH+UAdJPLkkJ1KMm+Z6X9PRQtd2E7cqw=";

  buildPhase = ''
    contracts=(
      "activate-bid"
      "add-bid"
      "delegate"
      "named-purse-payment"
      "transfer-to-account-u512"
      "undelegate"
      "withdraw-bid"
    )

    for contract in "''${contracts[@]}"; do
      cargo build --release --target=wasm32-unknown-unknown --manifest-path=smart_contracts/contracts/client/"$contract"/Cargo.toml
    done
  '';

  doCheck = false;

  installPhase = ''
    mkdir -p $out/;
    cp target/wasm32-unknown-unknown/release/*.wasm $out/
  '';
}
