{
  lib',
  ...
}:
let
  inherit (lib'.flake.hyprland.lua) mkWorkspaceRule;
in
{
  wayland.windowManager.hyprland.settings.workspace_rule = map mkWorkspaceRule [
    {
      workspace = "10";
      monitor = 1;
      default = true;
    }
  ];
}
