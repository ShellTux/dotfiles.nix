{ config, lib, ... }:
let
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool;

  cfg = config.programs.diff-so-fancy;
in
{
  options.programs.diff-so-fancy = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    programs.diff-so-fancy = mkDefault {
      enableGitIntegration = true;

      settings = {
        changeHunkIndicators = true;
        markEmptyLines = true;
        rulerWidth = 80;
        useUnicodeRuler = true;
      };
    };
  };
}
