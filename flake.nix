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
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, rust-overlay, agenix, ... }:
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
    nixpkgs.lib.recursiveUpdate
      {
        herculesCI.ciSystems = [ "x86_64-linux" "aarch64-linux" ];

        overlays.default = import ./overlay.nix;

        nixosModules.casper-node =
          { pkgs, lib, ... }:
          {
            imports = [ ./nixos/modules/casper-node.nix ];
            services.casper-node.package = self.packages.${pkgs.system}.casper-node;
          };

        checks.x86_64-linux =
          let
            pkgs = nixpkgs.legacyPackages.x86_64-linux;
          in
          {
            casper-node-smoke-test =
              pkgs.callPackage ./nixos/tests/casper-node/smoke-test.nix {
                casperNodeModule = self.nixosModules.casper-node;
                agenixModule = agenix.nixosModules.age;
              };
            casper-node-private-network-test =
              pkgs.callPackage ./nixos/tests/casper-node/private-network-test.nix {
                casperNodeModule = self.nixosModules.casper-node;
                inherit (self.packages.x86_64-linux) casper-client-rs;
              };
          };
      }
      (eachDefaultSystem (system:
        let
          pkgs = nixpkgs.legacyPackages.${system}.extend (import rust-overlay);
          csprpkgs = pkgs.callPackage ./scope.nix { makeScope = pkgs.lib.makeScope; };
        in
        {
          packages = {
            inherit (csprpkgs)
              casper-node
              casper-node_2
              casper-node-contracts
              casper-node-launcher
              casper-client-rs
              casper-client-rs_2
              casper-sidecar
              ;
          };
          formatter = pkgs.nixpkgs-fmt;

          checks.format = pkgs.runCommand "format-check" { buildInputs = [ pkgs.nixpkgs-fmt ]; } ''
            set -euo pipefail
            cd ${self}
            nixpkgs-fmt --check .
            touch $out
          '';
        })
      );
}
