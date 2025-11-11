{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.programs.yazi;
in
{
  programs.yazi = mkIf cfg.enable {
    plugins = { inherit (pkgs.yaziPlugins) mediainfo; };

    extraPackages = [
      pkgs.mediainfo
      pkgs.ffmpeg
      pkgs.imagemagick
    ];

    settings = {
      plugin = {
        prepend_preloaders = [
          {
            mime = "{audio,video,image}/*";
            run = "mediainfo";
          }
          {
            mime = "application/subrip";
            run = "$mediainfo";
          }
        ];

        prepend_previewers = [
          {
            mime = "{audio,video,image}/*";
            run = "mediainfo";
          }
          {
            mime = "application/subrip";
            run = "mediainfo";
          }
        ];
      };
    };

  };
}
