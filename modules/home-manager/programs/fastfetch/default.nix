{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption mkIf;
  inherit (lib.types) bool;

  cfg = config.programs.fastfetch;
in
{
  options.programs.fastfetch = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    programs.fastfetch = {
      settings = {
        "$schema" = "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json";

        logo.padding.top = 1;

        display = {
          separator = " 󰑃  ";
          # bar = {
          #   charElapsed = "=";
          #   charTotal = "-";
          #   width = 13;
          # };
          # percent.type = 2;
        };

        modules = [
          "break"

          # System
          {
            type = "host";
            key = "󰌢 SYSTEM";
            keyColor = "green";
          }
          {
            type = "cpu";
            key = "│ ├";
            keyColor = "green";
          }
          {
            type = "memory";
            key = "│ ├";
            keyColor = "green";
          }
          {
            type = "swap";
            key = "│ ├󰓡";
            keyColor = "green";
          }
          {
            type = "gpu";
            key = "│ ├󰾲";
            format = "{2}";
            keyColor = "green";
          }
          {
            type = "disk";
            key = "│ ├󰉉";
            keyColor = "green";
          }
          {
            type = "display";
            key = "│ ├󰍹";
            keyColor = "green";
            compactType = "original-with-refresh-rate";
          }
          {
            type = "battery";
            key = "│ └";
            keyColor = "green";
          }
          # {
          #   type = "localip";
          #   key = "│ ├󰩟";
          #   keyColor = "green";
          # }
          # {
          #   type = "publicip";
          #   key = "│ ├󰩠";
          #   keyColor = "green";
          #   timeout = 1000;
          # }

          # Distro
          {
            type = "os";
            key = " DISTRO";
            keyColor = "yellow";
          }
          {
            type = "kernel";
            key = "│ ├";
            keyColor = "yellow";
          }
          {
            type = "packages";
            key = "│ ├󰏖";
            keyColor = "yellow";
          }
          {
            type = "locale";
            key = "│ └";
            keyColor = "yellow";
          }

          # Desktop
          {
            type = "wm";
            key = " DE/WM";
            keyColor = "blue";
          }
          {
            type = "cursor";
            key = "│ ├";
            keyColor = "blue";
          }
          {
            type = "wmtheme";
            key = "│ ├󰉼";
            keyColor = "blue";
          }
          {
            type = "icons";
            key = "│ └󰀻";
            keyColor = "blue";
          }

          # Terminal
          {
            type = "terminal";
            key = " TERMINAL";
            keyColor = "green";
          }
          {
            type = "shell";
            key = "│ ├";
            keyColor = "green";
          }
          {
            type = "terminalfont";
            key = "│ └";
            keyColor = "green";
          }

          # Audio
          {
            type = "sound";
            key = " AUDIO";
            format = "{2}";
            keyColor = "magenta";
          }
          {
            type = "player";
            key = "│ ├󰥠";
            keyColor = "magenta";
          }
          {
            type = "media";
            key = "│ └󰝚";
            keyColor = "magenta";
          }

          "break"

          {
            type = "colors";
            key = "";
            symbol = "circle";
          }
        ];
      };
    };
  };
}
