{ makeScope, newScope, writeShellScriptBin }:
makeScope newScope (self: {
  casper-node = self.callPackage ./pkgs/casper-node { };
  casper-node-contracts = self.callPackage ./pkgs/casper-node-contracts { };
  casper-node-launcher = self.callPackage ./pkgs/casper-node-launcher { };
  casper-client-rs = self.callPackage ./pkgs/casper-client-rs { };
})
