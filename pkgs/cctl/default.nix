{ stdenv
, lib
, fetchFromGitHub
, casper-client-rs
, casper-node
, casper-node-launcher
, casper-node-contracts
, binutils
, python3
, symlinkJoin
}:
let
  cspr-bins = symlinkJoin {
    name = "cspr-bins";
    paths = [
      casper-client-rs
      casper-node
      casper-node-launcher
      casper-node-contracts
    ];
  };
  python = python3.withPackages (ps: with ps; [ supervisor tomlkit toml ]);
in
stdenv.mkDerivation {
  pname = "cctl";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "casper-network";
    repo = "cctl";
    rev = "69af101815a6e43f91159d096319de4912f3f2c8";
    sha256 = "sha256-bkZ4DF0DCqIE0NJrluenIAsS79WIjeCOsGlzKTWz74E=";
  };

  buildPhase = ''
    mkdir $out
    echo $src
    shopt -s globstar # Enable recursive globbing
    for file in "$src"/**/*.sh; do
      if [ -f "$file" ]; then
        relative_path="''${file#$src/}"
        target_path="$out/$relative_path"
        mkdir -p "$(dirname "$target_path")"
        cp $file $target_path
        chmod +x $target_path
      fi
    done
    cp -r $src/resources $out/resources


    echo "export CCTL=$out" >> $out/activate
    echo "export CCTL_ASSETS=./assets" >> $out/activate
    echo "export CSPR_PATH_TO_RESOURCES=${casper-node.src}/resources" >> $out/activate
    echo "export CSPR_PATH_TO_BIN=${cspr-bins}/bin" >> $out/activate
    echo "export PATH=\$PATH:${lib.makeBinPath [ binutils python ] }" >> $out/activate
    cp "$src"/activate "$out"/.activate-wrapped
    chmod +x "$out"/.activate-wrapped
    echo "source $out/.activate-wrapped" >> $out/activate
  '';
}
