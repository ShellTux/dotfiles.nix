{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool;

  cfg = config.boot.plymouth;
in
{
  options.boot.plymouth = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    boot.plymouth = mkDefault {
      theme = "bgrt";
      themePackages = [
        pkgs.nixos-bgrt-plymouth
        pkgs.catppuccin-plymouth
      ];
    };
  };
}
