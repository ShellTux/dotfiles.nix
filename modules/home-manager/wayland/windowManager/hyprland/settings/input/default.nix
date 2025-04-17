{
  lib,
  ...
}:
let
  inherit (lib) mkDefault;
in
{
  wayland.windowManager.hyprland.settings.input = mkDefault {
    kb_layout = "pt";

    follow_mouse = 1;

    touchpad = {
      natural_scroll = "no";
      disable_while_typing = true;
    };

    sensitivity = 0;
    numlock_by_default = true;
  };
}
