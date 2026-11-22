{
  config,
  lib,
  lib',
  ...
}:
let
  inherit (lib) mkIf;
  inherit (lib'.flake.hyprland.lua) mkExecOnce mkLuaCall;

  cfg = config.wayland.windowManager.hyprland;
in
{
  config.wayland.windowManager.hyprland.settings = mkIf (cfg.enable && !cfg.disableModule) {
    on = map mkLuaCall [
      [
        "window.open"
        ./window.open.lua
      ]
      [
        "hyprland.start"
        (mkExecOnce cfg.exec-once)
      ]
      [
        "window.title"
        ./bitwarden-window.title.lua
      ]
    ];
  };
}
