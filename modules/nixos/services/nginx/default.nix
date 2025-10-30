{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool;

  cfg = config.services.nginx;
in
{
  options.services.nginx = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    services.nginx = mkDefault {
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
    };
  };
}
