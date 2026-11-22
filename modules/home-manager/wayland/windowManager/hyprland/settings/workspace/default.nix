{ config, lib, ... }:
let
  inherit (lib) mkIf;

  cfg = config.wayland.windowManager.hyprland;
in
{
  config = mkIf (cfg.enable && !cfg.disableModule) {
    wayland.windowManager.hyprland.settings.workspace_rule = [
      {
        workspace = "10";
        monitor = 1;
        default = true;
      }
    ];
  };
}
