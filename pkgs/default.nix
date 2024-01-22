{ pkgs, lib }:

lib.makeScope pkgs.newScope (self: with self; {
  casper-node = callPackage ./casper-node { };
  casper-node-launcher = callPackage ./casper-node-launcher { };
  casper-client-rs = callPackage ./casper-client-rs { };
})
