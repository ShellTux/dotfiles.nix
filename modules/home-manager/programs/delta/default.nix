{ config, lib, ... }:
let
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool;

  cfg = config.programs.delta;
in
{
  options.programs.delta = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    programs.delta = mkDefault {
      enableGitIntegration = true;

      options = {
        dark = true;
        light = false;
        navigate = true;
        line-numbers = true;
      };
    };
  };
}
