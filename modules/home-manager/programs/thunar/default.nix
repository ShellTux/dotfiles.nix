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
        pkgs.xfce4-exo
        pkgs.thunar-archive-plugin
        pkgs.thunar-media-tags-plugin
        pkgs.thunar-vcs-plugin
        pkgs.thunar-volman
        pkgs.tumbler
      ];
      type = listOf package;
      description = "List of thunar plugins to install.";
      example = literalExpression "with pkgs.xfce; [ thunar-archive-plugin thunar-volman ]";
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    home.packages = [
      pkgs.ffmpegthumbnailer
      (pkgs.thunar.override {
        thunarPlugins = cfg.plugins;
      })
    ];

    wayland.windowManager.hyprland.settings.windowrule = [
      (float { match = "initial_title (Rename:.*)"; })
      (float { match = "initial_title (Renomear:.*)"; })
      (float { match = "initial_title (File Operation Progress.*)"; })
      (float { match = "initial_title (Progresso da operação do ficheiro.*)"; })
    ];
  };
}
