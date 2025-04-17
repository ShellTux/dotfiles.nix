{
  lib,
  ...
}:
let
  inherit (lib) mkDefault;
in
{
  programs.nixvim.plugins.web-devicons.customIcons = mkDefault {
    m = {
      icon = "";
      name = "matlab";
    };
    oct = {
      icon = "";
      name = "octave";
    };
  };
}
