{
  lib,
  ...
}:
let
  inherit (lib) mkDefault;
in
{
  wayland.windowManager.hyprland.systemd.enable = mkDefault true;
}
