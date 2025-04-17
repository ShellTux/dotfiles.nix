{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkOption
    mkIf
    mkDefault
    getExe
    ;
  inherit (pkgs) callPackage;
  inherit (lib.types) bool;

  script = getExe (callPackage ./script { });

  cfg = config.services.wpaperd;
in
{
  options.services.wpaperd = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    services.wpaperd = mkDefault {
      settings = {
        default = {
          duration = "15m";
          exec = script;
          mode = "center";
          sorting = "random";
          transition-time = 1500;
        };

        any.path = "~/Wallpapers/static";
      };
    };
  };
}
