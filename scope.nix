{ makeScope, newScope }:
makeScope newScope (self: {
  casper-node = self.callPackage ./pkgs/casper-node { };
  casper-node_2 = self.callPackage ./pkgs/casper-node/2.nix { };
  casper-node-contracts = self.callPackage ./pkgs/casper-node-contracts { };
  casper-node-launcher = self.callPackage ./pkgs/casper-node-launcher { };
  casper-client-rs = self.callPackage ./pkgs/casper-client-rs { };
  casper-client-rs_2 = self.callPackage ./pkgs/casper-client-rs/2.nix { };
  casper-sidecar = self.callPackage ./pkgs/casper-sidecar { };
})
