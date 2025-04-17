{ config, lib, ... }:
let
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool;

  cfg = config.services.gammastep;
in
{
  options.services.gammastep = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    services.gammastep = mkDefault {
      dawnTime = "6:00-7:45";
      duskTime = "18:35-20:15";
      provider = "manual";
      tray = true;
    };
  };
}
