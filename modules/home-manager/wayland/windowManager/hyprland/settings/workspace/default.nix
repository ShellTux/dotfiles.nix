{
  lib,
  ...
}:
let
  inherit (lib) mkDefault;
in
{
  wayland.windowManager.hyprland.settings.workspace = mkDefault [
    "10, monitor:1, default:true"
  ];
}
