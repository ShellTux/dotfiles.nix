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
    literalExpression
    ;
  inherit (lib.types) bool listOf package;

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

    plugins = mkOption {
      default = [
        pkgs.xfce.exo
        pkgs.xfce.thunar-archive-plugin
        pkgs.xfce.thunar-media-tags-plugin
        pkgs.xfce.thunar-vcs-plugin
        pkgs.xfce.thunar-volman
        pkgs.xfce.tumbler
      ];
      type = listOf package;
      description = "List of thunar plugins to install.";
      example = literalExpression "with pkgs.xfce; [ thunar-archive-plugin thunar-volman ]";
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    home.packages = [
      pkgs.ffmpegthumbnailer
      (pkgs.xfce.thunar.override {
        thunarPlugins = cfg.plugins;
      })
    ];
  };
}
