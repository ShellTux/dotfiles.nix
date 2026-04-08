{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf getExe;

  mpc = getExe pkgs.mpc;
  playerctl = getExe pkgs.playerctl;
  wlogout = getExe pkgs.wlogout;

  span = color: text: "<span color='${color}'>${text}</span>";
in
mkIf (config.flavour == "config1") {
  settings = [
    {
      name = "top_bar";
      layer = "top";
      position = "top";
      height = 36;
      spacing = 4;
      modules-left = [
        "custom/logo"
        "hyprland/workspaces"
        "hyprland/submap"
      ];
      modules-center = [
        "clock#time"
        "custom/separator"
        "clock#week"
        "custom/separator_dot"
        "clock#month"
        "custom/separator"
        "clock#calendar"
      ];
      modules-right = [
        "bluetooth"
        "network"
        "group/misc"
        "custom/logout_menu"
      ];

      "custom/logo" = {
        "format" = "  ";
        "tooltip" = false;
      };

      "hyprland/workspaces" = {
        on-click = "activate";
        format = "{icon} {windows}";
        format-icons = {
          "1" = "1";
          "2" = "2";
          "3" = "3";
          "4" = "4";
          "5" = "5";
          "6" = "6";
          "7" = "7";
          "8" = "8";
          "9" = "9";
          "10" = "󰿬";
          special = "";

          # active = "";
          # default = "";
          # empty = "";
        };
        show-special = false;
        active-only = true;
        persistent-workspaces = {
          "*" = 10;
        };
      };

      "hyprland/submap" = {
        format = "${span "#a6da95" "Mode:"} {}";
        tooltip = false;
      };

      "clock#time" = {
        format = "{:%H:%M %Ez}";
      };

      "custom/separator" = {
        format = "|";
        tooltip = false;
      };

      "custom/separator_dot" = {
        format = "•";
        tooltip = false;
      };

      "clock#week" = {
        format = "{:%a}";
        locale = "pt_PT.UTF-8";
      };

      "clock#month" = {
        format = "{:%h}";
        locale = "pt_PT.UTF-8";
      };

      "clock#calendar" = {
        format = "{:%F}";
        tooltip-format = "<tt><small>{calendar}</small></tt>";
        actions = {
          on-click-right = "mode";
        };
        calendar = {
          mode = "month";
          mode-mon-col = 3;
          weeks-pos = "right";
          on-scroll = 1;
          on-click-right = "mode";
          format = {
            months = "<span color='#f4dbd6'><b>{}</b></span>";
            days = "<span color='#cad3f5'><b>{}</b></span>";
            weeks = "<span color='#c6a0f6'><b>W{}</b></span>";
            weekdays = "<span color='#a6da95'><b>{}</b></span>";
            today = "<span color='#8bd5ca'><b><u>{}</u></b></span>";
          };
        };
      };

      clock = {
        format = "{:%I:%M %p %Ez | %a • %h | %F}";
        format-alt = "{:%I:%M %p}";
        tooltip-format = "<tt><small>{calendar}</small></tt>";
        actions = {
          on-click-right = "mode";
        };
        calendar = {
          mode = "month";
          mode-mon-col = 3;
          weeks-pos = "right";
          on-scroll = 1;
          on-click-right = "mode";
          format = {
            months = "<span color='#f4dbd6'><b>{}</b></span>";
            days = "<span color='#cad3f5'><b>{}</b></span>";
            weeks = "<span color='#c6a0f6'><b>W{}</b></span>";
            weekdays = "<span color='#a6da95'><b>{}</b></span>";
            today = "<span color='#8bd5ca'><b><u>{}</u></b></span>";
          };
        };
      };

      "custom/media" = {
        format = "{icon} 󰎈";
        restart-interval = 2;
        return-type = "json";
        format-icons = {
          Playing = "";
          Paused = "";
        };
        max-length = 35;
        # exec = "fish -c fetch_music_player_data";
        on-click = "${playerctl} play-pause";
        on-click-right = "${playerctl} next";
        on-click-middle = "${playerctl} prev";
        on-scroll-up = "${playerctl} volume 0.05-";
        on-scroll-down = "${playerctl} volume 0.05+";
        smooth-scrolling-threshold = "0.1";
      };

      mpd = {
        format = "{stateIcon}{consumeIcon}{randomIcon}{repeatIcon}{singleIcon} {title}";
        tooltip-format = "Artist: {artist}\nAlbum: {album}\nTitle: {title}";
        on-click = "${mpc} toggle";
        on-click-middle = "${mpc} prev";
        on-click-right = "${mpc} next";
        on-scroll-down = "${mpc} volume +5";
        on-scroll-up = "${mpc} volume -5";
        consume-icons.on = " ";
        random-icons = {
          off = "<span color=\"#f53c3c\"> </span>";
          on = " ";
        };
        repeat-icons.on = " ";
        single-icons.on = "1 ";
        state-icons = {
          paused = "  ";
          playing = "  ";
        };
      };

      bluetooth = {
        format = "󰂯";
        format-disabled = "󰂲";
        format-connected = "󰂱 {device_alias}";
        format-connected-battery = "󰂱 {device_alias} (󰥉 {device_battery_percentage}%)";
        tooltip-format = "{controller_alias}\t{controller_address} ({status})\n\n{num_connections} connected";
        tooltip-format-disabled = "bluetooth off";
        tooltip-format-connected = "{controller_alias}\t{controller_address} ({status})\n\n{num_connections} connected\n\n{device_enumerate}";
        tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
        tooltip-format-enumerate-connected-battery = "{device_alias}\t{device_address}\t({device_battery_percentage}%)";
        on-click = "blueman-manager";
        max-length = 35;
      };

      network = {
        format = "󰤭";
        format-wifi = "{icon} {signalStrength}%";
        format-icons = [
          "󰤯"
          "󰤟"
          "󰤢"
          "󰤥"
          "󰤨"
        ];
        format-disconnected = "󰤫";
        tooltip-format = "wifi <span color='#ee99a0'>off</span>";
        tooltip-format-wifi = "SSID: {essid}({signalStrength}%); {frequency} MHz\nInterface: {ifname}\nIP: {ipaddr}\nGW: {gwaddr}\n\n<span color='#a6da95'>{bandwidthUpBits}</span>\t<span color='#ee99a0'>{bandwidthDownBits}</span>\t<span color='#c6a0f6'>󰹹{bandwidthTotalBits}</span>";
        tooltip-format-disconnected = "<span color='#ed8796'>disconnected</span>";
        format-ethernet = "󰈀 {ipaddr}/{cidr}";
        format-linked = "󰈀 {ifname} (No IP)";
        tooltip-format-ethernet = "Interface: {ifname}\nIP: {ipaddr}\nGW: {gwaddr}\nNetmask: {netmask}\nCIDR: {cidr}\n\n<span color='#a6da95'>{bandwidthUpBits}</span>\t<span color='#ee99a0'>{bandwidthDownBits}</span>\t<span color='#c6a0f6'>󰹹{bandwidthTotalBits}</span>";
        on-click = "pypr toggle nmtui";
        max-length = 35;
      };

      "group/misc" = {
        orientation = "horizontal";
        modules = [
          # "custom/webcam"
          # "privacy"
          # "custom/recording"
          # "custom/geo"
          "custom/media"
          "mpd"
          # "custom/night_mode"
          # "custom/airplane_mode"
          "idle_inhibitor"
        ];
      };

      #     "custom/webcam" = {
      #     "interval" = 1,
      #     "exec" = "fish -c check_webcam",
      #     "return-type" = "json",
      #   },
      #
      #   "privacy" = {
      #   "icon-spacing" = 1,
      #   "icon-size" = 12,
      #   "transition-duration" = 250,
      #   "modules" = [
      #   {
      #   "type" = "audio-in",
      # },
      # {
      #   "type" = "screenshare",
      #   },
      #   ]
      #   },
      #
      #   "custom/recording" = {
      #     "interval" = 1,
      #     "exec-if" = "pgrep wl-screenrec",
      #     "exec" = "fish -c check_recording",
      #     "return-type" = "json",
      #   },
      #
      #   "custom/geo" = {
      #   "interval" = 1,
      #   "exec-if" = "pgrep geoclue",
      #   "exec" = "fish -c check_geo_module",
      #   "return-type" = "json",
      #   },
      #
      #   "custom/airplane_mode" = {
      #     "return-type" = "json",
      #     "interval" = 1,
      #     "exec" = "fish -c check_airplane_mode",
      #     "on-click" = "fish -c airplane_mode_toggle",
      #   },
      #
      #   "custom/night_mode" = {
      #   "return-type" = "json",
      #   "interval" = 1,
      #   "exec" = "fish -c check_night_mode",
      #   "on-click" = "fish -c night_mode_toggle",
      #   },

      idle_inhibitor = {
        format = "{icon}";
        format-icons = {
          activated = "󰛐";
          deactivated = "󰛑";
        };
        tooltip-format-activated = "idle-inhibitor <span color='#a6da95'>on</span>";
        tooltip-format-deactivated = "idle-inhibitor <span color='#ee99a0'>off</span>";
        start-activated = false;
      };

      "custom/logout_menu" = {
        format = "";
        tooltip = false;
        on-click = "sh -c '(sleep 0.3s; ${wlogout} --protocol layer-shell)' & disown";
      };
    }
    {
      name = "bottom_bar";
      layer = "top";
      position = "bottom";
      height = 36;
      spacing = 4;
      modules-left = [ "user" ];
      modules-center = [ "hyprland/window" ];
      modules-right = [
        "keyboard-state"
        "hyprland/language"
      ];

      "hyprland/window" = {
        format = "👼 {title} 😈";
        max-length = 50;
      };

      "hyprland/language" = {
        format-en = "🇺🇸 ENG (US)";
        format-pt = "🇵🇹 POR (PT)";
      };

      keyboard-state = {
        capslock = true;
        numlock = true;
        format = "{name} {icon}";
        format-icons = {
          locked = "󰌾";
          unlocked = "󰍀";
        };
      };

      user = {
        format = " <span color='#8bd5ca'>{user}</span> (up <span color='#f5bde6'>{work_d} d</span> <span color='#8aadf4'>{work_H} h</span> <span color='#eed49f'>{work_M} min</span> <span color='#a6da95'>↑</span>)";
        icon = true;
      };
    }
    {
      name = "left_bar";
      layer = "bottom";
      position = "left";
      spacing = 4;
      width = 75;
      margin-top = 0;
      margin-bottom = 0;
      modules-left = [ "wlr/taskbar" ];
      modules-center = [
        "cpu"
        "memory"
        "disk"
        "temperature"
        "battery"
        "backlight"
        "pulseaudio"
        "systemd-failed-units"
      ];
      modules-right = [ "tray" ];

      "wlr/taskbar" = {
        format = "{icon}";
        icon-size = 20;
        icon-theme = "Numix-Circle";
        tooltip-format = "{title}";
        active-first = true;
        on-click = "activate";
        on-click-right = "close";
        on-click-middle = "fullscreen";
      };

      tray = {
        icon-size = 20;
        spacing = 2;
      };

      cpu = {
        format = " {usage}%";
        interval = 3;
        states = {
          high = 90;
          upper-medium = 70;
          medium = 50;
          lower-medium = 30;
          low = 10;
        };
        on-click = "pypr toggle btop";
        on-click-right = "pypr toggle htop";
      };

      memory = {
        format = " {percentage}%";
        tooltip-format = "Main: ({used} GiB/{total} GiB)({percentage}%), available {avail} GiB\nSwap: ({swapUsed} GiB/{swapTotal} GiB)({swapPercentage}%), available {swapAvail} GiB";
        states = {
          high = 90;
          upper-medium = 70;
          medium = 50;
          lower-medium = 30;
          low = 10;
        };
        on-click = "pypr toggle btop";
        on-click-right = "pypr toggle htop";
      };

      disk = {
        format = "󰋊 {percentage_used}%";
        tooltip-format = "({used}/{total})({percentage_used}%) in '{path}', available {free}({percentage_free}%)";
        states = {
          high = 90;
          upper-medium = 70;
          medium = 50;
          lower-medium = 30;
          low = 10;
        };
      };

      temperature = {
        tooltip = false;
        thermal-zone = 8;
        critical-threshold = 80;
        format = "{icon} {temperatureC}ºC";
        format-critical = "🔥{icon} {temperatureC}ºC";
        format-icons = [
          ""
          ""
          ""
          ""
          ""
        ];
      };

      battery = {
        states = {
          high = 90;
          upper-medium = 70;
          medium = 50;
          lower-medium = 30;
          low = 10;
        };
        format = "{icon} {capacity}%";
        format-charging = "󱐋 {icon} {capacity}%";
        format-plugged = "󰚥 {icon} {capacity}%";
        format-time = "{H} h {M} min";
        format-icons = [
          "󱃍"
          "󰁺"
          "󰁻"
          "󰁼"
          "󰁽"
          "󰁾"
          "󰁿"
          "󰂀"
          "󰂁"
          "󰂂"
          "󰁹"
        ];
        tooltip-format = "{timeTo}";
      };

      backlight = {
        format = "{icon} {percent}%";
        format-icons = [
          "󰌶"
          "󱩎"
          "󱩏"
          "󱩐"
          "󱩑"
          "󱩒"
          "󱩓"
          "󱩔"
          "󱩕"
          "󱩖"
          "󰛨"
        ];
        tooltip = false;
        states = {
          high = 90;
          upper-medium = 70;
          medium = 50;
          lower-medium = 30;
          low = 10;
        };
        reverse-scrolling = true;
        reverse-mouse-scrolling = true;
      };

      pulseaudio = {
        states = {
          high = 90;
          upper-medium = 70;
          medium = 50;
          lower-medium = 30;
          low = 10;
        };
        tooltip-format = "{desc}";
        format = "{icon} {volume}%\n{format_source}";
        format-bluetooth = "󰂱 {icon} {volume}%\n{format_source}";
        format-bluetooth-muted = "󰂱 󰝟 {volume}%\n{format_source}";
        format-muted = "󰝟 {volume}%\n{format_source}";
        format-source = "󰍬 {volume}%";
        format-source-muted = "󰍭 {volume}%";
        format-icons = {
          headphone = "󰋋";
          hands-free = "";
          headset = "󰋎";
          phone = "󰄜";
          portable = "󰦧";
          car = "󰄋";
          speaker = "󰓃";
          hdmi = "󰡁";
          hifi = "󰋌";
          default = [
            "󰕿"
            "󰖀"
            "󰕾"
          ];
        };
        reverse-scrolling = true;
        reverse-mouse-scrolling = true;
        on-click = "pypr toggle volume";
      };

      systemd-failed-units = {
        format = "✗ {nr_failed}";
      };
    }
  ];

  "style.css".path = ./style.css;
}
