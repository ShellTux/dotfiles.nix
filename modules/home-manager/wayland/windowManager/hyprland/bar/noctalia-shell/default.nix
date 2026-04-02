{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkDefault getExe;

  noctalia-shell = getExe cfg.bar.noctalia-shell;
  wofi = getExe pkgs.wofi;

  cfg = config.wayland.windowManager.hyprland;
in
{
  config = mkIf (cfg.enable && !cfg.disableModule && cfg.bar.noctalia-shell != null) {
    wayland.windowManager.hyprland.settings = {
      exec-once = [
        "${noctalia-shell}"
      ];

      bind = [
        # Toggle bar
        "$mainMod SHIFT, B, exec, pkill -SIGUSR1 waybar ; ${noctalia-shell} ipc call bar toggle"

        "$mainMod, P, exec, ${noctalia-shell} ipc call launcher toggle || ${wofi} --allow-images --show drun"

        "$mainMod SHIFT, N, exec, ${noctalia-shell} ipc call wallpaper random"
      ];
    };

    programs.hyprlock.enable = mkDefault false;
    services.hypridle.enable = mkDefault false;
  };
}
