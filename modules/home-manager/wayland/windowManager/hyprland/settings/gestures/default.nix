{
  lib,
  ...
}:
let
  inherit (lib) mkDefault;
in
{
  wayland.windowManager.hyprland.settings.gestures = mkDefault {
  };
}
