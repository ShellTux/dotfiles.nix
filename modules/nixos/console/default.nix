{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool;

  cfg = config.console;
in
{
  options.console = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    console = {
      font = mkDefault "ter-124b";
      packages = mkDefault [
        pkgs.terminus_font
      ];
    };
  };
}
