{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool;

  base16Scheme = colorscheme: "${pkgs.base16-schemes}/share/themes/${colorscheme}.yaml";

  cfg = config.stylix;
in
{
  options.stylix = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    stylix = mkDefault {
      base16Scheme = base16Scheme "catppuccin-mocha";

      homeManagerIntegration = {
        autoImport = false;
        followSystem = true;
      };
    };
  };
}
