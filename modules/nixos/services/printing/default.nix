{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool;

  cfg = config.services.printing;
in
{
  options.services.printing = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    services.printing = mkDefault {
      drivers = [ pkgs.brlaser ];
    };

    environment.systemPackages = [ pkgs.system-config-printer ];
  };
}
