{ pkgs, lib }:

lib.makeScope pkgs.newScope (self: with self; {
  casper-node = callPackage ./casper-node { };
  casper-node-contracts = callPackage ./casper-node-contracts { };
  casper-node-launcher = callPackage ./casper-node-launcher { };
  casper-client-rs = callPackage ./casper-client-rs { };
  cctl = callPackage ./cctl { };
})
