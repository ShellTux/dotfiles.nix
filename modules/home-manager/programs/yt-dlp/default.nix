{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool;

  cfg = config.programs.yt-dlp;
in
{
  options.programs.yt-dlp = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    programs.yt-dlp = mkDefault {
      settings = {
        embed-thumbnail = true;
        embed-subs = true;
        embed-metadata = true;
        embed-chapters = true;
        sub-langs = "all";
        format = ''"bestvideo[height<=1440]+bestaudio/best"'';
      };
    };
  };
}
