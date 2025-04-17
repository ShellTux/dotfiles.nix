{
  config,
  lib,
  ...
}:
let
  inherit (lib) getExe mkIf;

  terminal = getExe config.default.terminal;
  browser = getExe config.default.browser;

  cfg = config.wayland.windowManager.hyprland;
in
{
  imports = [
    ./bind
    ./decoration
    ./env
    ./exec
    ./exec-once
    ./general
    ./gestures
    ./input
    ./misc
    ./windowrule
    ./workspace
  ];

  config = mkIf (cfg.enable && !cfg.disableModule) {
    wayland.windowManager.hyprland.settings = {
      "$altMod" = "ALT";
      "$mainMod" = "SUPER";
      "$TERMINAL" = terminal;
      "$BROWSER" = browser;
      "$SCRATCHPAD" = terminal;
    };
  };
}
