{ config, lib, ... }:
let
  inherit (lib) mkIf mkDefault getExe;

  waybar = getExe cfg.bar.waybar;

  cfg = config.wayland.windowManager.hyprland;
in
{
  config = mkIf (cfg.enable && !cfg.disableModule && cfg.bar.waybar != null) {
    wayland.windowManager.hyprland.settings = {
      exec-once = [
        "${waybar}"
      ];

      bind = [
        # Toggle waybar
        "$mainMod SHIFT, B, exec, pkill -SIGUSR1 waybar"
      ];
    };

    programs.hyprlock.enable = mkDefault true;
    services.hypridle.enable = mkDefault true;
  };
}
