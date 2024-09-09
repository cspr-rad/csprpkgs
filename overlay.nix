final: prev: {
  casper-node = final.callPackage ./pkgs/casper-node { };
  casper-node_2 = final.callPackage ./pkgs/casper-node/2.nix { };
  casper-node-contracts = final.callPackage ./pkgs/casper-node-contracts { };
  casper-node-launcher = final.callPackage ./pkgs/casper-node-launcher { };
  casper-client-rs = final.callPackage ./pkgs/casper-client-rs { };
  casper-client-rs_2 = final.callPackage ./pkgs/casper-client-rs/2.nix { };
  casper-sidecar = final.callPackage ./pkgs/casper-sidecar { };
}
