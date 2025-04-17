{
  lib,
  ...
}:
let
  inherit (lib) mkDefault;

  envVar = env: value: "${env}, ${value}";
in
{
  # TODO: make size relative to screen size or some custom option
  wayland.windowManager.hyprland.settings.env = mkDefault [
    (envVar "GDK_BACKEND" "wayland,x11")
    (envVar "HYPRCURSOR_SIZE" "24")
    (envVar "XCURSOR_SIZE" "36")
  ];
}
