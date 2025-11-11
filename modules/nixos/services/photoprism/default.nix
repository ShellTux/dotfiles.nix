{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool;

  cfg = config.services.photoprism;
in
{
  options.services.photoprism = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    services.photoprism = mkDefault {
      settings = {
        PHOTOPRISM_DEFAULT_LOCALE = "pt";
      };
    };
  };
}
