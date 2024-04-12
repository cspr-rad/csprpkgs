{ lib, pkgs, config, ... }:
let
  inherit (lib)
    types
    mkOption
    mkIf
    mkMerge
    mkEnableOption
    ;
  cfg = config.services.casper-node;

  mapDotsToUnderscore = lib.stringAsChars (c: if c == "." then "_" else c);
  versionsAndHashes = {
    "1.5.6" = "sha256-2N2vPKHLKV32RzzZPV004hWH1/lbeZUf3WofTVm+ZZI=";
  };
  defaultConfigsSrc = {
    "production" =
      pkgs.fetchFromGitHub {
        owner = "casper-network";
        repo = "casper-protocol-release";
        rev = "refs/tags/casper-${cfg.package.version}";
        hash = versionsAndHashes.${cfg.package.version};
      };
    "local" = cfg.package.src.outPath;
  };
  chainspecTomlSrc = {
    "production" = "${defaultConfigsSrc."production"}/config/chainspec.toml";
    "local" = "${defaultConfigsSrc."local"}/resources/local/chainspec.toml.in";
  };
  defaultNodeConfigTomlSrc = {
    "production" = "${defaultConfigsSrc."production"}/config/config-example.toml";
    "local" = "${defaultConfigsSrc."local"}/resources/local/config.toml";
  };
in
{
  options.services.casper-node = {

    enable = mkEnableOption ("casper-node");

    package = mkOption {
      type = types.package;
    };

    genesisConfig = mkOption {
      type = types.enum [ "production" "local" ];
      default = "production";
      description = ''
        The genesis config type to use.
      '';
    };

    port = mkOption {
      type = types.port;
      default = 35000;
      example = 35000;
      description = ''
        Port to listen on.
      '';
    };

    publicAddress = mkOption {
      type = types.str;
      example = "https://casper.network:0";
      description = ''
        The public address other peer nodes should connect to.
      '';
    };

    logLevel = mkOption {
      type = types.str;
      default = "info";
      description = ''
        The log-level that should be used.
      '';
    };

    validatorSecretKeyPath = mkOption {
      type = types.path;
      description = ''
        The absolute path to the validator's secret key file used to sign consensus messages.
      '';
    };
  };

  config = mkIf cfg.enable {

    systemd.services.casper-node =
      {
        description = "casper-node";
        documentation = [ "https://docs.casper.network/operators/setup/" ];
        wantedBy = [ "multi-user.target" ];
        after = [ "network-online.target" ];
        requires = [ "network-online.target" ];
        environment = {
          RUST_LOG = cfg.logLevel;
        };
        serviceConfig = mkMerge [
          {
            ExecStart = "${lib.getExe cfg.package} standard /etc/casper/${mapDotsToUnderscore cfg.package.version}/config.toml";
            Restart = "always";
            User = "casper-node";
            Group = "casper-node";
            StateDirectory = "casper"; # creates /var/lib/casper
          }
        ];
      };

    # Explicit user and group definitions are required instead of using DynamicUser,
    # in order to work seemlessly with tools like agenix.
    # The agenix service runs and changes ownership of a secret before a service
    # with `DynamicUser=true` would create the user.
    users.users.casper-node = {
      name = "casper-node";
      group = "casper-node";
      isSystemUser = true;
    };

    users.groups.casper-node = { };

    environment.etc."casper/${mapDotsToUnderscore cfg.package.version}/chainspec.toml".source = chainspecTomlSrc.${cfg.genesisConfig};
    environment.etc."casper/${mapDotsToUnderscore cfg.package.version}/config.toml" =
      let
        defaultNodeConfig = builtins.fromTOML (builtins.readFile defaultNodeConfigTomlSrc.${cfg.genesisConfig});

        finalNodeConfig = lib.recursiveUpdate defaultNodeConfig {
          network = {
            bind_address = "0.0.0.0:${builtins.toString cfg.port}";
            public_address = "${cfg.publicAddress}";
          };
          consensus.secret_key_path = cfg.validatorSecretKeyPath;
        };
      in
      {
        source = (pkgs.formats.toml { }).generate "config.toml" finalNodeConfig;
      };
  };
}
