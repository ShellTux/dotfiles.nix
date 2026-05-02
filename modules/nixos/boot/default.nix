{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkOption
    mkIf
    mkDefault
    getExe'
    ;
  inherit (lib.types) bool;
  inherit (pkgs) fetchpatch;

  cfg = config.boot;
in
{
  imports = [
    ./loader
    ./plymouth
  ];

  options.boot = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (!cfg.disableModule) {
    boot = {
      kernelPackages = mkDefault pkgs.linuxPackages_latest;
      kernelParams = [
        "quiet"
        "splash"

        "boot.shell_on_fail"
        "loglevel=3"
        "rd.systemd.show_status=false"
        "rd.udev.log_level=3"
        "udev.log_priority=3"
      ];

      consoleLogLevel = mkDefault 0;

      # FIX(CVE-2026-31431): remove when patched
      kernelPatches = [
        {
          name = "CVE-2026-31431";
          patch = fetchpatch {
            url = "https://github.com/torvalds/linux/commit/a664bf3d603dc3bdcf9ae47cc21e0daec706d7a5.patch";
            sha256 = "sha256-bI8clRA/oaL6X1Egmh+GlzpTOmZQu42TlJ4ySS9yayk=";
          };
        }
      ];
      blacklistedKernelModules = [ "algif_aead" ];
      extraModprobeConfig = "install algif_aead ${getExe' pkgs.coreutils "false"}";
    };
  };
}
