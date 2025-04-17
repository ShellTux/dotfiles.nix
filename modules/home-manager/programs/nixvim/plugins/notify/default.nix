{
  lib,
  ...
}:
let
  inherit (lib) mkDefault;
in
{
  programs.nixvim.plugins.notify.settings = mkDefault {
    background_color = "#000000";
    background_colour = "#000000";
  };
}
