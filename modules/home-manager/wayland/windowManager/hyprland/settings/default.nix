{
  config,
  lib,
  lib',
  ...
}:
let
  inherit (lib) getExe getName mkIf;
  inherit (lib'.flake.hyprland.lua) mkVars;

  terminal = getName config.flake.defaultApplications.terminal;
  browser = getExe config.flake.defaultApplications.browser;

  cfg = config.wayland.windowManager.hyprland;
in
{
  imports = [
    ./bind
    ./decoration
    ./env
    ./exec-once
    ./general
    ./gestures
    ./input
    ./misc
    ./windowrule
    ./workspace
  ];

  config = mkIf (cfg.enable && !cfg.disableModule) {
    wayland.windowManager.hyprland.settings = mkVars {
      altMod = "ALT";
      mainMod = "SUPER";
      TERMINAL = terminal;
      BROWSER = browser;
      SCRATCHPAD = terminal;
    };
  };
}
