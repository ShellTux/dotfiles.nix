{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool;

  cfg = config.services.upower;
in
{
  options.services.upower = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    services.upower = mkDefault {
      percentageAction = 15;
      percentageCritical = 20;
      percentageLow = 25;
    };
  };
}
