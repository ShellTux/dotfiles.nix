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
    ;
  inherit (lib.types) bool;
  inherit (flake-lib.hyprland.windowrule) idleinhibit;

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

    wayland.windowManager.hyprland.settings.windowrule = [
      (idleinhibit {
        match = "class org.jellyfin.JellyfinDesktop";
        idle_inhibit = "focus";
      })
    ];
  };
}
