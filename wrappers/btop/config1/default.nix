{ lib, config, ... }:
let
  inherit (lib) mkIf mkDefault;
in
mkIf (config.flavour == "config1") {
  settings = {
    color_theme = mkDefault "tokyo-night";
    proc_sorting = "cpu lazy";
    theme_background = false;
    update_ms = 200;
    vim_keys = true;
  };
}
