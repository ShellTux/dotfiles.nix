{
  lib,
  config,
  pkgs,
  flake-pkgs,
  ...
}:
let
  inherit (lib) getExe mkIf;

  brightness = getExe flake-pkgs.brightness;
  hyprshot = getExe pkgs.hyprshot;
  mpc-cli = getExe pkgs.mpc-cli;
  pypr = getExe pkgs.pyprland;
  rofi = getExe (
    pkgs.rofi.override {
      plugins = [ pkgs.rofi-emoji ];
    }
  );
  volume = getExe flake-pkgs.volume;
  wlogout = getExe pkgs.wlogout;
  wofi = getExe pkgs.wofi;
  woomer = getExe pkgs.woomer;

  hyprshot_dir = "${config.xdg.userDirs.pictures}/hyprshot/";

  cfg = config.wayland.windowManager.hyprland;
in
{
  config = mkIf (cfg.enable && !cfg.disableModule) {
    wayland.windowManager.hyprland.settings = {
      bind = [
        "$mainMod, Return, exec, $TERMINAL"
        "$mainMod, C, killactive, "
        "$mainMod, P, exec, ${wofi} --allow-images --show drun"
        "$mainMod SHIFT, Q, exec, hyprctl dispatch exit"

        "$mainMod, Space, togglefloating, "
        "$altMod, Tab, cyclenext, "
        "$mainMod, F, fullscreen, 0"

        "$mainMod, H, movefocus, l"
        "$mainMod, L, movefocus, r"
        "$mainMod, K, movefocus, u"
        "$mainMod, J, movefocus, d"

        # Switch workspaces with mainMod + [0-9]"
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"
        "$mainMod, right, workspace, e+1"
        "$mainMod, left, workspace, e-1"
        "$mainMod, U, focusurgentorlast"
        "$mainMod, TAB, focusurgentorlast"

        # Move active window to a workspace with mainMod + SHIFT + [0-9]
        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"
        "$mainMod SHIFT, 6, movetoworkspace, 6"
        "$mainMod SHIFT, 7, movetoworkspace, 7"
        "$mainMod SHIFT, 8, movetoworkspace, 8"
        "$mainMod SHIFT, 9, movetoworkspace, 9"
        "$mainMod SHIFT, 0, movetoworkspace, 10"
        "$mainMod CTRL SHIFT, right, movetoworkspace, e+1"
        "$mainMod CTRL SHIFT, left, movetoworkspace, e-1"

        "$mainMod SHIFT, Tab, movecurrentworkspacetomonitor, +1"

        # Screenshots
        ", PRINT, exec, ${hyprshot} --mode=output --output-folder='${hyprshot_dir}'"
        "$mainMod, PRINT, exec, ${hyprshot} --mode=window --output-folder='${hyprshot_dir}'"
        "$mainMod SHIFT, PRINT, exec, ${hyprshot} --mode=region --output-folder='${hyprshot_dir}'"

        # Emojis
        "$mainMod, period, exec, ${rofi} -show emoji"

        # wlogout
        "$mainMod, F4, exec, ${wlogout} --protocol layer-shell"

        # Pin Window (Sticky)
        "$mainMod ALT, S, pin, active"

        # Monocle
        "$mainMod SHIFT, m, exec, hyprctl dispatch fullscreen 1"

        # Zoom
        "$mainMod, Plus, exec, ${woomer}"

        # Pypr
        "$mainMod , Z, exec, ${pypr} zoom ++0.5"
        "$mainMod SHIFT, Z, exec, ${pypr} zoom"

        "$mainMod, B, exec, ${pypr} toggle btop"
        "$mainMod, E, exec, ${pypr} toggle yazi"
        "$mainMod, M, exec, ${pypr} toggle ncmpcpp"
        "$mainMod, R, exec, ${pypr} toggle htop"
        "$mainMod, N, exec, ${pypr} toggle nvtop"
        "$mainMod, S, exec, ${pypr} toggle term"
        "$mainMod, X, exec, ${pypr} toggle qalc"

        "$mainMod, backslash, exec, ${pypr} toggle-dpms"

        "$mainMod SHIFT, apostrophe, exec, ${pypr} menu"

        # Toggle waybar
        "$mainMod SHIFT, B, exec, pkill -SIGUSR1 waybar"
      ];

      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"

        # Center floating window
        "$mainMod, mouse:274, centerwindow"
      ];

      bindl = [
        # Music
        ", XF86AudioPlay, exec, ${mpc-cli} toggle"
        ", XF86AudioPrev, exec, ${mpc-cli} prev"
        ", XF86AudioNext, exec, ${mpc-cli} next"
      ];

      bindle = [
        # Volume
        ", XF86AudioRaiseVolume, exec, ${volume} 5 +"
        ", XF86AudioLowerVolume, exec, ${volume} 5 -"
        "SHIFT, XF86AudioRaiseVolume, exec, ${volume} 1 +"
        "SHIFT, XF86AudioLowerVolume, exec, ${volume} 1 -"
        ", XF86AudioMute, exec, ${volume} toggle-mute"

        # Brightness
        ", XF86MonBrightnessUp,    exec, ${brightness} 5 +"
        ", XF86MonBrightnessDown,  exec, ${brightness} 5 -"
      ];
    };
  };
}
