{ config, lib, ... }:
let
  inherit (lib) mkOption mkIf;
  inherit (lib.types) bool;

  cfg = config.services.easyeffects;
in
{
  imports = [
    ./extraPresets
  ];

  options.services.easyeffects = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    dconf.enable = true;
  };
}
