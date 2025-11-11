{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption mkIf;
  inherit (lib.types) bool;

  cfg = config.programs.yazi;
in
{
  imports = [
    ./keymap
    ./plugins
    ./settings
    ./theme
  ];

  options.programs.yazi = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    programs.yazi = {
      extraPackages = [
        pkgs.exiftool
        pkgs.imv
        pkgs.mpv
      ];

      settings = {
        opener = rec {
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

        };

        open.rules = [
          {
            mime = "text/*";
            use = [
              "edit"
              "reveal"
            ];
          }
          {
            mime = "image/*";
            use = [
              "image"
              "reveal"
            ];
          }
          {
            mime = "video/*";
            use = [
              "video"
              "reveal"
            ];
          }
          {
            mime = "audio/*";
            use = [
              "audio"
              "reveal"
            ];
          }
          {
            mime = "application/json";
            use = [
              "edit"
              "reveal"
            ];
          }
        ];

      };
    };
  };
}
