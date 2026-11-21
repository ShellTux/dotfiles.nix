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
  inherit (lib.generators) mkLuaInline;
  inherit (lib'.flake.hyprland.lua) mkBinds mkOptsBinds;

  brightness = getExe self'.packages.brightness;
  hyprshot = getExe pkgs.hyprshot;
  mpc = getExe pkgs.mpc;
  rofi = getExe (
    pkgs.rofi.override {
      plugins = [
        pkgs.rofi-emoji
        pkgs.rofi-calc
      ];
    }
  );
  volume = getExe self'.packages.volume;
  wlogout = getExe pkgs.wlogout;
  wofi = getExe pkgs.wofi;
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
        "SUPER + SHIFT + C".dsp.window.kill = [ ];
        "SUPER + SHIFT + Q".dsp.exit = [ ];
        # "SUPER + SHIFT + R".dsp.reload_config = [ ];

        # Show current Hyprland binds
        # "SUPER + SHIFT + slash".dsp.exec_cmd = [
        #   ''
        #     hyprctl -j binds | jq -r '.[] | \"\(.key)  →  \(.dispatcher) \(.arg // \"\")\"' | ${wofi} --dmenu --prompt 'Hyprland shortcuts'
        #   ''
        # ];

        "SUPER + Space".dsp.window.float = [ { action = "toggle"; } ];
        "SUPER + SHIFT + Return".dsp.window.fullscreen = [
          {
            action = "toggle";
            mode = "maximized";
          }
        ];

        # Focus
        "SUPER + H".dsp.focus = [ { direction = "left"; } ];
        "SUPER + L".dsp.focus = [ { direction = "right"; } ];
        "SUPER + K".dsp.focus = [ { direction = "up"; } ];
        "SUPER + J".dsp.focus = [ { direction = "down"; } ];
        "ALT + TAB".dsp.window.cycle_next = [ ];
        "SUPER + TAB".dsp.focus = [ { last = true; } ];
        "SUPER + right".dsp.focus = [ { workspace = "e+1"; } ];
        "SUPER + left".dsp.focus = [ { workspace = "e-1"; } ];
        "SUPER + CTRL + right".dsp.focus = [ { monitor = "+1"; } ];
        "SUPER + CTRL + left".dsp.focus = [ { monitor = "-1"; } ];

        # Move and resize windows
        "SUPER + SHIFT + H".dsp.window.move = [ { direction = "left"; } ];
        "SUPER + SHIFT + L".dsp.window.move = [ { direction = "right"; } ];
        "SUPER + SHIFT + K".dsp.window.move = [ { direction = "up"; } ];
        "SUPER + SHIFT + J".dsp.window.move = [ { direction = "down"; } ];
        "SUPER + ALT + R".dsp.submap = [ "resize" ];
        "SUPER + CTRL + SHIFT + right".dsp.window.move = [
          {
            monitor = "+1";
            follow = true;
          }
        ];
        "SUPER + CTRL + SHIFT + left".dsp.window.move = [
          {
            monitor = "-1";
            follow = true;
          }
        ];

        # Move the current workspace between monitors
        "SUPER + ALT + SHIFT + right".dsp.workspace.move = [ { monitor = "+1"; } ];
        "SUPER + ALT + SHIFT + left".dsp.workspace.move = [ { monitor = "-1"; } ];

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

        # Named special workspace (scratchpad)
        "SUPER + SHIFT + S".dsp.workspace.toggle_special = [ "scratchpad" ];
        "SUPER + SHIFT + ALT + S".dsp.window.move = [
          {
            workspace = "special:scratchpad";
            follow = true;
          }
        ];

        # Monocle
        "SUPER + SHIFT + M".dsp.window.fullscreen = [ { action = "toggle"; } ];

        # Zoom
        "SUPER + Plus".dsp.exec_cmd = [ woomer ];
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
        "XF86AudioMute".dsp.exec_cmd = [ "${volume} toggle" ];
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

    wayland.windowManager.hyprland.settings.define_submap = {
      _args = [
        "resize"
        (mkLuaInline ''
          function()
              hl.bind("h", hl.dsp.window.resize({ x = -10, y = 0, relative = true }, { repeating = true }))
              hl.bind("l", hl.dsp.window.resize({ x = 10, y = 0, relative = true }), { repeating = true })
              hl.bind("k", hl.dsp.window.resize({ x = 0, y = -10, relative = true }), { repeating = true })
              hl.bind("j", hl.dsp.window.resize({ x = 0, y = 10, relative = true }), { repeating = true })
              hl.bind("Escape", hl.dsp.submap("reset"))
          end
        '')
      ];
    };
  };
}
