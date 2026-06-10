{
  config,
  pkgs,
  lib,
  lib',
  ...
}:
let
  inherit (lib) mkIf mkDefault getExe;
  inherit (lib'.flake.hyprland.lua) mkBinds;

  waybar = getExe cfg.bar.waybar;
  wofi = getExe pkgs.wofi;

  cfg = config.wayland.windowManager.hyprland;
in
{
  config = mkIf (cfg.enable && !cfg.disableModule && cfg.bar.waybar != null) {
    wayland.windowManager.hyprland = {
      exec-once = [
        "${waybar}"
      ];

      settings.bind = mkBinds {
        "SUPER + P".dsp.exec_cmd = [ "${wofi} --allow-images --show drun" ];

        # Toggle waybar
        "SUPER + SHIFT + B".dsp.exec_cmd = [ "pkill -SIGUSR1 waybar" ];
      };
    };

    programs.hyprlock.enable = mkDefault true;
    services.hypridle.enable = mkDefault true;
  };
}
