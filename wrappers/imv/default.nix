{
  config,
  wlib,
  lib,
  ...
}:
let
  inherit (lib) mkOption;
  inherit (lib.types) enum;
in
{
  imports = [ wlib.wrapperModules.imv ];

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
          options = {
            overlay = true;
            overlay_text = ''[$imv_current_index/$imv_file_count] [$imv_widthx$imv_height] [$imv_scale%] [$imv_scaling_mode] $(basename "$imv_current_file")'';
          };
        }
      else
        null;
  };
}
