{
  self',
  lib,
  lib',
  config,
  pkgs,
  ...
}:
let
  inherit (builtins) listToAttrs;
  inherit (lib)
    getExe
    mkIf
    mod
    pipe
    range
    ;
  inherit (lib'.flake.hyprland.lua) mkBinds mkOptsBinds;

  brightness = getExe self'.packages.brightness;
  hyprshot = getExe pkgs.hyprshot;
  mpc = getExe pkgs.mpc;
  rofi = getExe pkgs.rofi;
  volume = getExe self'.packages.volume;
  wlogout = getExe pkgs.wlogout;
  woomer = getExe pkgs.woomer;

  hyprshot_dir = "${config.xdg.userDirs.pictures}/hyprshot/";

  cfg = config.wayland.windowManager.hyprland;
in
{
  config = mkIf (cfg.enable && !cfg.disableModule) {
    wayland.windowManager.hyprland.settings.bind =
      mkBinds {
        "SUPER + Return".dsp.exec_cmd = [ "\" .. TERMINAL .. \"" ];
        "SUPER + C".dsp.window.close = [ ];
        "SUPER + SHIFT + Q".dsp.exit = [ ];
        "SUPER + Space".dsp.window.float = [ { action = "toggle"; } ];
        "SUPER + H".dsp.focus = [ { direction = "left"; } ];
        "SUPER + L".dsp.focus = [ { direction = "right"; } ];
        "SUPER + K".dsp.focus = [ { direction = "up"; } ];
        "SUPER + J".dsp.focus = [ { direction = "down"; } ];
        "SUPER + right".dsp.focus = [ { workspace = "e+1"; } ];
        "SUPER + left".dsp.focus = [ { workspace = "e-1"; } ];

        # Move active window to a workspace with mainMod + SHIFT + [0-9]
        "SUPER + SHIFT + right".dsp.window.move = [ { workspace = "e+1"; } ];
        "SUPER + SHIFT + left".dsp.window.move = [ { workspace = "e-1"; } ];

        # Screenshots
        "PRINT".dsp.exec_cmd = [ "${hyprshot} --mode=output --output-folder='${hyprshot_dir}'" ];
        "SUPER + PRINT".dsp.exec_cmd = [ "${hyprshot} --mode=window --output-folder='${hyprshot_dir}'" ];
        "SUPER + SHIFT + PRINT".dsp.exec_cmd = [
          "${hyprshot} --mode=region --output-folder='${hyprshot_dir}'"
        ];

        # Emojis
        "SUPER + period".dsp.exec_cmd = [ "${rofi} -show emoji" ];

        # wlogout
        "SUPER + F4".dsp.exec_cmd = [ "${wlogout} --protocol layer-shell" ];

        # Pin Window (Sticky)
        "SUPER + ALT + S".dsp.window.pin = [ { action = "active"; } ];

        # Monocle
        "SUPER + SHIFT + M".dsp.window.fullscreen = [ { action = "toggle"; } ];

        # Zoom
        "SUPER + Plus".dsp.exec_cmd = [ woomer ];

        # "ALT + TAB".dsp.window = [ ];
        # "SUPER + F".dsp.window = [ ];
        # "SUPER + U".dsp.focus = [ { urgent_or_last = true; } ];
        # "SUPER + TAB".dsp.focus = [ { urgent_or_last = true; } ];
      }
      ++ pipe (range 1 10) [
        (map (number: {
          name = "SUPER + ${toString (mod number 10)}";
          value.dsp.focus = [ { workspace = number; } ];
        }))
        listToAttrs
        mkBinds
      ]
      ++ pipe (range 1 10) [
        (map (number: {
          name = "SUPER + SHIFT + ${toString (mod number 10)}";
          value.dsp.window.move = [ { workspace = number; } ];
        }))
        listToAttrs
        mkBinds
      ]
      ++ mkOptsBinds { locked = true; } {
        # Music
        "XF86AudioPlay".dsp.exec_cmd = [ "${mpc} toggle" ];
        "XF86AudioNext".dsp.exec_cmd = [ "${mpc} next" ];
        "XF86AudioPrev".dsp.exec_cmd = [ "${mpc} prev" ];
      }
      ++
        mkOptsBinds
          {
            locked = true;
            repeating = true;
          }
          {
            # Volume
            "XF86AudioRaiseVolume".dsp.exec_cmd = [ "${volume} 5 +" ];
            "XF86AudioLowerVolume".dsp.exec_cmd = [ "${volume} 5 -" ];
            "SHIFT + XF86AudioRaiseVolume".dsp.exec_cmd = [ "${volume} 1 +" ];
            "SHIFT + XF86AudioLowerVolume".dsp.exec_cmd = [ "${volume} 1 -" ];

            # Brightness
            "XF86MonBrightnessUp".dsp.exec_cmd = [ "${brightness} 5 +" ];
            "XF86MonBrightnessDown".dsp.exec_cmd = [ "${brightness} 5 -" ];
          }
      ++ mkOptsBinds { mouse = true; } {
        "SUPER + mouse:272".dsp.window.drag = [ ];
        "SUPER + mouse:273".dsp.window.resize = [ ];
        "SUPER + mouse:274".dsp.window.center = [ ];
      };
  };
}
