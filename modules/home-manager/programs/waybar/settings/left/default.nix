{ config, lib, ... }:
let
  inherit (lib) mkIf mkDefault;

  cfg = config.programs.waybar;
in
{
  config = mkIf (cfg.enable && !cfg.disableModule) {
    programs.waybar.settings.left = mkDefault {
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
    };
  };
}
