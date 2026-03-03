{ config, lib, ... }:
let
  inherit (lib) mkOption mkIf;
  inherit (lib.types) bool;

  cfg = config.services.hyprshell;
in
{
  options.services.hyprshell = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    services.hyprshell = {
      # TODO
    };
  };
}
