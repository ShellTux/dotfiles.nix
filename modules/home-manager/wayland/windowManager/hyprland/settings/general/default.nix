{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkDefault;
  inherit (config.lib.stylix.colors) cyan green;
in
{
  wayland.windowManager.hyprland.settings.config.general = {
    border_size = 3;
    col = {
      active_border = {
        colors = [
          "rgb(${cyan})"
          "rgb(${green})"
        ];
        angle = 45;
      };
      inactive_border = mkDefault "rgba(595959aa)";
    };
    gaps_in = 5;
    gaps_out = 20;
    layout = "master";
  };
}
