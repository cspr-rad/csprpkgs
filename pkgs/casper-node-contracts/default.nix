{ makeRustPlatform
, fetchFromGitHub
, rust-bin
}:
let
  rust-wasm32 = rust-bin.nightly."2023-03-25".default.override {
    extensions = [ ];
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
  version = "1.5.6";

  src = fetchFromGitHub {
    owner = "casper-network";
    repo = "casper-node";
    rev = "v${version}";
    sha256 = "sha256-Jm5f8gzX5HYkQMjEI4dV3ooVPyxhpf/lGyryyuAapqI=";
  };


  cargoHash = "sha256-SuwUX/g00HzxLWdv1yNU4Jj4oHCvYwg6dyGnFtG8rJo=";

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
