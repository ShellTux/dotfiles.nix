{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool;

  cfg = config.programs.rofi;
in
{
  options.programs.rofi = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    programs.rofi = mkDefault {
      plugins = [
        pkgs.rofi-bluetooth
        pkgs.rofi-calc
        pkgs.rofi-emoji
        pkgs.rofimoji
        pkgs.rofi-mpd
        pkgs.rofi-network-manager
        pkgs.rofi-pass
        pkgs.rofi-power-menu
        pkgs.rofi-rbw
        pkgs.rofi-screenshot
        pkgs.rofi-top
        pkgs.rofi-vpn
        pkgs.rofi-wayland
      ];
    };
  };
}
