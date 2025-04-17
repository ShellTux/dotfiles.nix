{
  config,
  lib,
  pkgs,
  flake-pkgs,
  ...
}:
let
  inherit (lib) mkOption mkIf mkForce;
  inherit (lib.types) bool;

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
        ];
        package = mkForce pkgs.kdePackages.sddm;
        theme = mkForce "sddm-astronaut-theme";
        wayland.enable = true;
      };
    };

    environment.systemPackages = [
      (pkgs.sddm-astronaut.override {
        embeddedTheme = "japanese_aesthetic";
      })
      flake-pkgs.sddm-lain-wired-theme
    ];

    # To prevent getting stuck at shutdown
    systemd.settings.Manager.DefaultTimeoutStopSec = "10s";
  };
}
