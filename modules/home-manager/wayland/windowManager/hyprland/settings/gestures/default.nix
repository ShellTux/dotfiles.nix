{
  lib,
  ...
}:
let
  inherit (lib) mkDefault;
in
{
  wayland.windowManager.hyprland.settings.gestures = mkDefault {
    workspace_swipe = "on";
    workspace_swipe_fingers = 3;
  };
}
