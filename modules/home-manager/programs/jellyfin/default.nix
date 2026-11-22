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
    mkEnableOption
    ;
  inherit (lib.types) bool;

  cfg = config.programs.jellyfin;
in
{
  options.programs.jellyfin = {
    enable = mkEnableOption "Wether to install Jellyfin Desktop";

    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    home.packages = [
      pkgs.delfin
      pkgs.finamp
      pkgs.jellyfin-desktop
    ];
  };
}
