{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption mkIf;
  inherit (lib.types) bool;

  cfg = config.hardware.graphics;
in
{
  options.hardware.graphics = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    hardware.graphics = {
      extraPackages = (
        mkIf (config.hardware.cpu.brand == "intel") [
          pkgs.intel-media-driver # For Broadwell (2014) or newer processors. LIBVA_DRIVER_NAME=iHD
          # pkgs.intel-ocl # Unfree
          pkgs.intel-vaapi-driver # For older processors. LIBVA_DRIVER_NAME=i965
        ]
      );

      extraPackages32 = (
        mkIf (config.hardware.cpu.brand == "intel" [ pkgs.pkgsi686Linux.intel-vaapi-driver ])
      );
    };
  };
}
