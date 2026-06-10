{
  config,
  lib,
  lib',
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkDefault getExe;
  inherit (lib'.flake.hyprland.lua) mkBinds;

  noctalia-shell = getExe cfg.bar.noctalia-shell;
  wofi = getExe pkgs.wofi;

  cfg = config.wayland.windowManager.hyprland;
in
{
  config = mkIf (cfg.enable && !cfg.disableModule && cfg.bar.noctalia-shell != null) {
    wayland.windowManager.hyprland = {
      exec-once = [
        "${noctalia-shell}"
      ];

      settings.bind = mkBinds {
        # Toggle bar
        "SUPER + SHIFT + B".dsp.exec_cmd = [
          "pkill -SIGUSR1 waybar ; ${noctalia-shell} ipc call bar toggle"
        ];
        "SUPER + P".dsp.exec_cmd = [ "${noctalia-shell} ipc call launcher toggle" ];
        "SUPER + SHIFT + P".dsp.exec_cmd = [ "${wofi} --allow-images --show drun" ];
        "SUPER + SHIFT + N".dsp.exec_cmd = [ "${noctalia-shell} ipc call wallpaper random" ];
      };
    };

    programs.hyprlock.enable = mkDefault false;
    services.hypridle.enable = mkDefault false;
  };
}
