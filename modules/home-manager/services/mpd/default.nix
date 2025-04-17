{
  config,
  lib,
  pkgs,
  flake-pkgs,
  ...
}:
let
  inherit (builtins) readFile;
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool listOf package;

  cfg = config.services.mpd;
in
{
  options.services.mpd = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };

    extraPackagesToInstall = mkOption {
      description = "Extra packages to install alongside enabling mpd service";
      type = listOf package;
      default = [
        flake-pkgs.notify-music
        pkgs.mpc-cli
        pkgs.playerctl
        pkgs.rmpc
      ];
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    services.mpd = mkDefault {
      network.startWhenNeeded = true;

      extraConfig = readFile ./extraConfig.conf;
      playlistDirectory = "${config.services.mpd.musicDirectory}/.mpd_playlists";
    };

    home.packages = cfg.extraPackagesToInstall;
  };
}
