final: prev: {
  casper-node = final.callPackage ./pkgs/casper-node { };
  casper-node-contracts = final.callPackage ./pkgs/casper-node-contracts { };
  casper-node-launcher = final.callPackage ./pkgs/casper-node-launcher { };
  casper-client-rs = final.callPackage ./pkgs/casper-client-rs { };
}
