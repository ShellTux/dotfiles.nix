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
    enable = mkEnableOption "Wether to install jellyfin-media-player";

    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    warnings = [
      "jellyfin-media-player is disabled because it depends on qtwebengine which is a insecure package"
    ];

    home.packages = [
      pkgs.delfin
      pkgs.finamp
      # pkgs.jellyfin-media-player
      # pkgs.jellyflix
    ];

    wayland.windowManager.hyprland.settings.windowrule = [
      "idleinhibit, focus, class:Jellyfin Media Player"
      "idleinhibit, focus, class:org.jellyfin.jellyfinmediaplayer"
    ];
  };
}
