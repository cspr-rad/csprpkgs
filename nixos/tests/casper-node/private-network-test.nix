{ nixosTest
, casperNodeModule
, casper-client-rs
}:
let
  port = 35001;
  knownAddresses = [
    "192.168.1.2:${builtins.toString port}"
    "192.168.1.3:${builtins.toString port}"
    "192.168.1.4:${builtins.toString port}"
    "192.168.1.5:${builtins.toString port}"
    "192.168.1.6:${builtins.toString port}"
  ];

  mkCasperNodeServerConfig = { id, publicAddress, knownAddresses }:
    { config, pkgs, lib, ... }: {
      imports = [
        casperNodeModule
        ./reset-time.nix
      ];
      services.reset-time.enable = true;
      networking.firewall.allowedTCPPorts = [ config.services.casper-node.port 7777 ];
      networking.interfaces.eth1.ipv4.addresses = lib.mkOverride 0 [{ address = publicAddress; prefixLength = 24; }];
      services.casper-node = {
        enable = true;
        inherit knownAddresses port;
        genesisConfig = "local";
        publicAddress = "${publicAddress}:${builtins.toString config.services.casper-node.port}"; # public address assigned by nixos test driver
        validatorSecretKeyPath = "${config.services.casper-node.package.src.outPath}/resources/local/secret_keys/node-${builtins.toString id}.pem";
      };
    };
in
nixosTest {
  name = "casper-node private-network test";

  nodes = {
    server1 = mkCasperNodeServerConfig { id = 1; publicAddress = "192.168.1.2"; inherit knownAddresses; };
    server2 = mkCasperNodeServerConfig { id = 2; publicAddress = "192.168.1.3"; inherit knownAddresses; };
    server3 = mkCasperNodeServerConfig { id = 3; publicAddress = "192.168.1.4"; inherit knownAddresses; };
    server4 = mkCasperNodeServerConfig { id = 4; publicAddress = "192.168.1.5"; inherit knownAddresses; };
    server5 = mkCasperNodeServerConfig { id = 5; publicAddress = "192.168.1.6"; inherit knownAddresses; };

    client = { config, pkgs, lib, ... }: {
      environment.systemPackages = [ casper-client-rs ];
      networking.interfaces.eth1.ipv4.addresses = lib.mkOverride 0 [{ address = "192.168.1.200"; prefixLength = 24; }];
    };
  };

  testScript = ''
    import json

    start_all()
    server1.wait_for_unit("casper-node.service")
    server2.wait_for_unit("casper-node.service")
    server3.wait_for_unit("casper-node.service")
    server4.wait_for_unit("casper-node.service")
    server5.wait_for_unit("casper-node.service")

    client.wait_for_unit("network-online.target")
    server1.wait_for_open_port(7777)

    def node_is_validating(node: str):
      def _node_is_validating(_) -> bool:
        result = json.loads(client.succeed("casper-client get-node-status --node-address http://{}:7777".format(node)))
        return result["result"]["reactor_state"] == "Validate"
      return _node_is_validating

    with client.nested("waiting for nodes to reach validate reactor state"):
      retry(node_is_validating("server1"))
      retry(node_is_validating("server2"))
      retry(node_is_validating("server3"))
      retry(node_is_validating("server4"))
      # retry(node_is_validating("server5")) # TODO figure out why this one stays in KeepUp
  '';
}
