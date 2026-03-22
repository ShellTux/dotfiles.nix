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
    mkForce
    mkDefault
    ;
  inherit (lib.types) bool;
  inherit (pkgs.nixos-artwork) wallpapers;

  themes.sddm-lain-wired-theme = pkgs.callPackage ./sddm-lain-wired-theme.nix { };
  custom-elegant-sddm = pkgs.elegant-sddm.override {
    themeConfig.General.background = "${wallpapers.simple-dark-gray-bottom.gnomeFilePath}";
  };

  cfg = config.services.displayManager;
in
{
  options.services.displayManager = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    services.displayManager = {
      sddm = {
        autoNumlock = true;
        extraPackages = [
          pkgs.kdePackages.qtmultimedia
          pkgs.kdePackages.qtsvg
          pkgs.kdePackages.qtvirtualkeyboard
          custom-elegant-sddm
        ];
        theme = mkDefault "Elegant";
        wayland.enable = true;
      };
    };

    environment.systemPackages = [
      themes.sddm-lain-wired-theme
      custom-elegant-sddm
    ];

    # To prevent getting stuck at shutdown
    systemd.settings.Manager.DefaultTimeoutStopSec = "10s";
  };
}
