{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkIf
    mkDefault
    getExe
    recursiveUpdate
    pipe
    ;

  scratchpad =
    { program, ... }@scratchpad:
    pipe scratchpad [
      (recursiveUpdate {
        animation = "fromTop";
        class = "kitty-dropterm";
        command = "[TERMINAL] -e ${program}";
        lazy = true;
        margin = 50;
        unfocus = "hide";
      })
      (scratchpad: removeAttrs scratchpad [ "program" ])
    ];

in
mkIf (config.flavour == "config1") {
  runtimePkgs = [
    # pkgs.btop
    # pkgs.htop
    # pkgs.ncmpcpp
    # pkgs.qalc
    # pkgs.nmtui
  ];

  settings = {
    pyprland = {
      plugins = [
        "magnify"
        "scratchpads"
        "shortcuts_menu"
        "toggle_dpms"
      ];

      variables = {
        TERMINAL = "kitty";
      };
    };

    magnify.duration = 25;

    scratchpads = {
      btop = scratchpad {
        program = "btop";
        animation = "fromBottom";
        max_size = "1920px 100%";
        size = "95% 70%";
      };

      htop = scratchpad {
        program = "htop";
        animation = "fromBottom";
        max_size = "1920px 100%";
        size = "75% 70%";
      };

      ncmpcpp = scratchpad {
        program = "ncmpcpp";
        animation = "fromRight";
        size = "90% 65%";
      };

      nmtui = scratchpad {
        program = "nmtui";
        animation = "fromRight";
        size = "40% 90%";
      };

      nvtop = scratchpad {
        program = "nvtop";
        animation = "fromBottom";
        max_size = "1920px 100%";
        size = "75% 70%";
      };

      qalc = scratchpad {
        program = "qalc";
        animation = "fromTop";
        max_size = "1920px 100%";
        size = "85% 40%";
      };

      term = {
        animation = "fromTop";
        class = "kitty-dropterm";
        command = "[TERMINAL]";
        margin = 50;
        max_size = "1920px 100%";
        size = "75% 70%";
      };

      volume = {
        animation = "fromRight";
        class = "org.pulseaudio.pavucontrol";
        command = "pavucontrol";
        lazy = true;
        size = "40% 90%";
        unfocus = "hide";
      };

      yazi = {
        animation = "fromLeft";
        class = "kitty-dropterm";
        command = "[TERMINAL_CLASSED] -e yazi";
        margin = 50;
        max_size = "1920px 100%";
        size = "75% 85%";
      };
    };

    shortcuts_menu = {
      entries = {
        "Clipboard history" = [
          {
            command = "cliphist list";
            filter = "s/\t.*//";
            name = "entry";
          }
          "cliphist decode '[entry]' | wl-copy"
        ];

        "Color picker" = [
          {
            name = "format";
            options = [
              "hex"
              "rgb"
              "hsv"
              "hsl"
              "cmyk"
            ];
          }
          "sleep 0.2; hyprpicker --autocopy --format=[format]"
        ];

        "Restart waybar" = [ "pkill waybar && waybar & disown" ];
        annotate = [
          {
            command = "ls /tmp/shot_*.png";
            name = "fname";
          }
          "satty --filename '[fname]' --output-filename '/tmp/annotated.png'"
        ];

        screenshot = [
          {
            name = "what";
            options = [
              "output"
              "window"
              "region"
              "active"
            ];
          }
          "hyprshot --mode [what] --output-folder /tmp --filename shot_[what].png"
        ];
      };
    };
  };
}
