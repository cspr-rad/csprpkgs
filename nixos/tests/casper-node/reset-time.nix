{ lib, pkgs, config, ... }:
let
  inherit (lib)
    mkIf
    mkMerge
    mkEnableOption
    ;
  cfg = config.services.reset-time;
in
{
  options.services.reset-time = {

    enable = mkEnableOption ("reset-time");

  };

  config = mkIf cfg.enable {

    systemd.services.reset-time =
      {
        description = "Reset System Time to Epoch 0";
        wantedBy = [ "multi-user.target" ];
        serviceConfig = mkMerge [
          {
            ExecStart = "${pkgs.coreutils}/bin/date -s '1970-01-01 01:00:00'";
            Type = "oneshot";
          }
        ];
      };

  };
}
