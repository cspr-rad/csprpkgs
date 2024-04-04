{
  description = "A collection of casper related packages";

  nixConfig = {
    extra-substituters = [
      "https://cspr.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cspr.cachix.org-1:vEZlmbOsmTXkmEi4DSdqNVyq25VPNpmSm6qCs4IuTgE="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, rust-overlay, ... }:
    let
      eachSystem = systems: f:
        let
          # Merge together the outputs for all systems.
          op = attrs: system:
            let
              ret = f system;
              op = attrs: key: attrs //
                {
                  ${key} = (attrs.${key} or { })
                    // { ${system} = ret.${key}; };
                }
              ;
            in
            builtins.foldl' op attrs (builtins.attrNames ret);
        in
        builtins.foldl' op { } systems;

      eachDefaultSystem = eachSystem [
        "aarch64-darwin"
        "x86_64-darwin"
        "x86_64-linux"
      ];
    in
    {
      herculesCI.ciSystems = [ "x86_64-linux" ];
      overlays.default = import ./overlay.nix;
    }
    // eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system}.extend (import rust-overlay);
        csprpkgs = pkgs.callPackage ./scope.nix { makeScope = pkgs.lib.makeScope; };
      in
      {
        packages = {
          inherit (csprpkgs)
            casper-node
            casper-node-contracts
            casper-node-launcher
            casper-client-rs
            ;
        };
        formatter = pkgs.nixpkgs-fmt;

        checks.format = pkgs.runCommand "format-check" { buildInputs = [ pkgs.nixpkgs-fmt ]; } ''
          set -euo pipefail
          cd ${self}
          nixpkgs-fmt --check .
          touch $out
        '';
      });
}
