{ config, lib, ... }:
let
  inherit (lib) mkIf mkDefault;

  cfg = config.programs.yt-dlp;
in
mkIf (cfg.enable && cfg.flavour == "config1") {
  programs.yt-dlp.settings = mkDefault {
    embed-thumbnail = true;
    embed-subs = true;
    embed-metadata = true;
    embed-chapters = true;
    sub-langs = "all";
    format = ''"bestvideo[height<=1440]+bestaudio/best"'';
  };
}
