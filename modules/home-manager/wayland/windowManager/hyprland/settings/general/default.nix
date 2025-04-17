{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkForce mkDefault;
  inherit (config.lib.stylix.colors) cyan green;
in
{
  wayland.windowManager.hyprland.settings.general = {
    border_size = 3;
    "col.active_border" = mkForce "rgb(${cyan}) rgb(${green}) 45deg";
    "col.inactive_border" = mkDefault "rgba(595959aa)";
    gaps_in = 5;
    gaps_out = 20;
    layout = "master";
  };
}
