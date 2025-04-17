{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption mkIf mkEnableOption;
  inherit (lib.types) bool;

  cfg = config.programs.thunar;
in
{
  options.programs.thunar = {
    enable = mkEnableOption "Wether to install thunar";

    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    home.packages = [
      pkgs.ffmpegthumbnailer
      pkgs.xfce.exo
      pkgs.xfce.thunar
      pkgs.xfce.thunar-archive-plugin
      pkgs.xfce.thunar-media-tags-plugin
      pkgs.xfce.thunar-vcs-plugin
      pkgs.xfce.thunar-volman
      pkgs.xfce.tumbler
    ];
  };
}
