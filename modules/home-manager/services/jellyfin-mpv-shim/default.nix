{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool;

  cfg = config.services.jellyfin-mpv-shim;
in
{
  options.services.jellyfin-mpv-shim = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    services.jellyfin-mpv-shim = mkDefault { };

    home.packages = [ pkgs.jellyfin-mpv-shim ];

    xdg.autostart.entries = [
      "${pkgs.jellyfin-mpv-shim}/share/applications/jellyfin-mpv-shim.desktop"
    ];
  };
}
