{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool listOf package;

  cfg = config.services.desktopManager.cosmic;
in
{
  options.services.desktopManager.cosmic = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };

    installPackages = mkOption rec {
      description = "Useful packages to install along side with cosmic";
      type = listOf package;
      default = [
        # Hardware/System Utilities (Optional)
        pkgs.kdePackages.isoimagewriter # Write hybrid ISOs to USB
        pkgs.kdePackages.partitionmanager # Disk and partition management
        pkgs.hardinfo2 # System benchmarks and hardware info
        pkgs.wayland-utils # Wayland diagnostic tools
        pkgs.wl-clipboard # Wayland copy/paste support
        pkgs.vlc # Media player
      ];
      example = default;
    };

    excludePackages = mkOption {
      description = "Useful packages to install along side with plasma6";
      type = listOf package;
      default = [ ];
      example = [
        pkgs.cosmic-edit
      ];
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    services.desktopManager.cosmic = { };

    services = {
      displayManager.cosmic-greeter.enable = mkDefault true;
      system76-scheduler.enable = mkDefault true;
    };

    environment = {
      cosmic.excludePackages = cfg.excludePackages;
      systemPackages = [ ] ++ cfg.installPackages;
    };

  };
}
