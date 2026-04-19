{ lib, config, ... }:
let
  inherit (lib) mkIf;
in
mkIf (config.flavour == "config1") {
  settings.options = {
    overlay = true;
    overlay_text = ''[$imv_current_index/$imv_file_count] [$imv_widthx$imv_height] [$imv_scale%] [$imv_scaling_mode] $(basename "$imv_current_file")'';
  };
}
