{ lib', ... }:
let
  inherit (lib'.flake.hyprland.lua) mkEnvVars;
in
{
  # TODO: make size relative to screen size or some custom option
  wayland.windowManager.hyprland.settings.env = mkEnvVars {
    GDK_BACKEND = "wayland,x11";
    HYPRCURSOR_SIZE = "24";
    XCURSOR_SIZE = "36";
  };
}
