{ config, lib, ... }:
let
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool;

  cfg = config.programs.vesktop;
in
{
  options.programs.vesktop = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    programs.vesktop = {
      settings = {
        appBadge = false;
        arRPC = true;
        checkUpdates = mkDefault false;
        customTitleBar = mkDefault false;
        disableMinSize = mkDefault true;
        minimizeToTray = mkDefault false;
        splashTheming = mkDefault true;
        staticTitle = true;
        hardwareAcceleration = true;
        discordBranch = mkDefault "stable";
      };
    };
  };
}
