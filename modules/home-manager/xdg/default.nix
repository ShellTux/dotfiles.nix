{ config, lib, ... }:
let
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool;

  cfg = config.xdg;
in
{
  imports = [
    ./mimeApps
    ./userDirs
  ];

  options.xdg = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    xdg = mkDefault {
      userDirs.enable = true;
      mimeApps.enable = true;
    };
  };
}
