{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool listOf package;

  cfg = config.services.desktopManager.plasma6;
in
{
  options.services.desktopManager.plasma6 = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };

    installPackages = mkOption rec {
      description = "Useful packages to install along side with plasma6";
      type = listOf package;
      default = [
        # KDE Utilities
        pkgs.kdePackages.discover # Optional: Software center for Flatpaks/firmware updates
        pkgs.kdePackages.kcalc # Calculator
        pkgs.kdePackages.kcharselect # Character map
        pkgs.kdePackages.kclock # Clock app
        pkgs.kdePackages.kcolorchooser # Color picker
        pkgs.kdePackages.kolourpaint # Simple paint program
        pkgs.kdePackages.ksystemlog # System log viewer
        pkgs.kdePackages.sddm-kcm # SDDM configuration module
        pkgs.kdiff3 # File/directory comparison tool
      ]
      ++ [
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
        pkgs.kdePackages.plasma-browser-integration
        pkgs.kdePackages.konsole
        pkgs.kdePackages.elisa
      ];
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    services.desktopManager.plasma6 = { };

    services = {
      displayManager = {
        plasma-login-manager.enable = mkDefault true;
        # sddm.enable = mkDefault true;
      };
    };

    environment = {
      plasma6.excludePackages = cfg.excludePackages;
      systemPackages = [ ] ++ cfg.installPackages;
    };

  };
}
