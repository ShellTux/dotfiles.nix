{
  lib,
  ...
}:
let
  inherit (lib) mkDefault;
in
{
  wayland.windowManager.hyprland.systemd = mkDefault {
    enable = true;
  };
}
