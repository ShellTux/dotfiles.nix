{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.programs.mpv;
in
{
  config = mkIf (cfg.enable && !cfg.disableModule) {
    programs.mpv.profiles = {
      "extension.gif" = {
        loop-file = "inf";
      };

      "big-cache" = {
        cache = "yes";
        demuxer-max-bytes = "1GiB";
      };

      "network" = {
        profile-cond = "demuxer_via_network == true";
        profile-desc = "Profile for content over the network";
        profile = "big-cache";
      };

      "1080p" = {
        ytdl-format = "ytdl-format=bestvideo[height<=?1080]+bestaudio/best";
      };

      "720p" = {
        ytdl-format = "ytdl-format=bestvideo[height<=?720]+bestaudio/best";
      };

      "480p" = {
        ytdl-format = "ytdl-format=bestvideo[height<=?480]+bestaudio/best";
      };

      "360p" = {
        ytdl-format = "ytdl-format=bestvideo[height<=?360]+bestaudio/best";
      };
    };
  };
}
