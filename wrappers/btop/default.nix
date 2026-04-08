{
  config,
  wlib,
  lib,
  ...
}:
let
  inherit (lib) mkDefault mkOption;
  inherit (lib.types) enum;
in
{
  imports = [ wlib.wrapperModules.btop ];

  options = {
    flavour = mkOption {
      type = enum [
        "none"
        "config1"
      ];
      default = "config1";
      description = ''
        Which flavour of configuration to pick:
        - `none`: No configuration, allowed to change
        - `config1`: Not allowed to change.
      '';
    };
  };

  config = {
    settings =
      if config.flavour == "none" then
        { }
      else if config.flavour == "config1" then
        {
          color_theme = mkDefault "tokyo-night";
          proc_sorting = "cpu lazy";
          theme_background = false;
          update_ms = 200;
          vim_keys = true;
        }
      else
        null;
  };
}
