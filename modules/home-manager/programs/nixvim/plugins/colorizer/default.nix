{
  lib,
  ...
}:
let
  inherit (lib) mkDefault;
in
{
  programs.nixvim.plugins.colorizer.settings.filetypes = mkDefault {
    __unkeyed-1 = "*";
    __unkeyed-2 = "!vim";
    css.gb_fn = true;
    html.names = false;
  };
}
