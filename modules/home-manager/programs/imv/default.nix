{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool;

  cfg = config.programs.imv;
in
{
  options.programs.imv = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) (mkDefault {
    programs.imv = {
      settings.options = {
        overlay = true;
        overlay_text = ''[$imv_current_index/$imv_file_count] [$imv_widthx$imv_height] [$imv_scale%] [$imv_scaling_mode] $(basename "$imv_current_file")'';
      };
    };

    xdg.mimeApps.defaultApplications =
      let
        imvDesktop = [ "imv.desktop" ];
      in
      {
        "image/gif" = imvDesktop;
        "image/png" = imvDesktop;
        "image/apng" = imvDesktop;
        "image/avif" = imvDesktop;
        "image/jpeg" = imvDesktop;
        "image/webp" = imvDesktop;
        "image/svg+xml" = imvDesktop;
      };
  });
}
