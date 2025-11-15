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
  programs.yazi = mkIf (cfg.enable && !cfg.disableModule) {

    extraPackages = [
      pkgs.exiftool
      pkgs.imv
      pkgs.mpv
      pkgs.unar
    ];

    settings.opener = rec {
      play = [
        {
          run = ''mpv "$@"'';
          block = true;
          for = "unix";
        }
      ];
      video = play;
      audio = play;

      edit = [
        {
          run = ''$EDITOR "$@"'';
          block = true;
          for = "unix";
        }
        {
          run = ''nvim "$@"'';
          block = true;
          for = "unix";
        }
        {
          run = ''vim "$@"'';
          block = true;
          for = "unix";
        }
        {
          run = ''nano "$@"'';
          block = true;
          for = "unix";
        }
      ];

      open = [
        {
          run = ''xdg-open "$@"'';
          desc = "Open";
        }
      ];

      image = [
        {
          run = ''imv "$@"'';
          block = true;
          for = "linux";
        }
      ];

      extract = [
        {
          run = ''unar "$1"'';
          desc = "Extract here";
          for = "unix";
        }
      ];
    };
  };
}
