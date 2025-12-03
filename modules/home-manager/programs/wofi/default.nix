{
  config,
  lib,
  pkgs,
  flake-lib,
  ...
}:
let
  inherit (builtins) elem;
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool;
  inherit (flake-lib.hyprland.windowrule) noborder;

  isInstalled = elem pkgs.wofi config.home.packages;

  cfg = config.programs.wofi;
in
{
  options.programs.wofi = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = {
    programs.wofi = mkIf ((cfg.enable || isInstalled) && !cfg.disableModule) {
      settings = mkDefault {
        allow_images = true;
        gtk_dark = true;
        insensitive = true;
        location = "center";
      };
    };

    wayland.windowManager.hyprland.settings.windowrule = [
      (noborder "class:^wofi$")
    ];
  };
}
