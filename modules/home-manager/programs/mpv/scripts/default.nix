{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkDefault;

  cfg = config.programs.mpv;
in
{
  config = mkIf (cfg.enable && !cfg.disableModule) {
    programs.mpv.scripts =
      let
        inherit (pkgs) mpvScripts;
      in
      mkDefault [
        mpvScripts.mpv-cheatsheet
        mpvScripts.mpv-playlistmanager
        mpvScripts.quality-menu
        mpvScripts.thumbfast
        mpvScripts.uosc
        mpvScripts.videoclip
        mpvScripts.webtorrent-mpv-hook
      ];
  };
}
