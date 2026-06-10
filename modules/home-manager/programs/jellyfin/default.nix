{
  config,
  lib,
  pkgs,
  lib',
  ...
}:
let
  inherit (lib)
    mkOption
    mkIf
    mkEnableOption
    ;
  inherit (lib.types) bool;
  inherit (lib'.flake.hyprland.lua) mkWindowRuleIdleInhibit;

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

    wayland.windowManager.hyprland.settings.window_rule = map (mkWindowRuleIdleInhibit "focus") [
      { match.class = "org.jellyfin.JellyfinDesktop"; }
    ];
  };
}
