{
  config,
  lib,
  pkgs,
  flake-lib,
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
  inherit (flake-lib.hyprland.windowrule) float;

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

    wayland.windowManager.hyprland.settings.windowrule = [
      (float "initialClass:thunar, title:(Rename:.*)")
      (float "initialClass:thunar, title:(Renomear:.*)")
      (float "initialClass:thunar, title:(File Operation Progress.*)")
      (float "initialClass:thunar, title:(Progresso da operação do ficheiro.*)")
    ];
  };
}
