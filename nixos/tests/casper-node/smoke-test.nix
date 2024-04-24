{ nixosTest
, casperNodeModule
, agenixModule
}:
let
  hostName = "casper-node";
  port = 35001;
in
nixosTest {
  name = "casper-node smoke test";

  nodes = {
    server = { config, pkgs, lib, ... }: {
      imports = [
        casperNodeModule
        agenixModule
        ./install-test-ssh-host-keys.nix
      ];

      age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      age.secrets.validator-secret-key = {
        file = ../../../secrets/validator-secret-key.age;
        mode = "500";
        owner = config.systemd.services.casper-node.serviceConfig.User;
        group = config.systemd.services.casper-node.serviceConfig.Group;
      };

      networking.hostName = hostName;
      services.casper-node = {
        enable = true;
        inherit port;
        publicAddress = "10.0.0.1:0"; # public address assigned by nixos test driver
        validatorSecretKeyPath = config.age.secrets.validator-secret-key.path;
      };
    };
  };

  testScript = ''
    start_all()
    casper_node.wait_for_unit("casper-node.service")
    casper_node.wait_for_open_port(${builtins.toString port})
  '';
}
