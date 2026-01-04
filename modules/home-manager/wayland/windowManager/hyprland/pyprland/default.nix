{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  inherit (builtins) readFile;
  inherit (lib)
    mkOption
    mkEnableOption
    mkIf
    getExe
    ;
  inherit (lib.types) bool;

  pypr = getExe inputs.pyprland.packages.${pkgs.stdenv.hostPlatform.system}.default;

  hypr-cfg = config.wayland.windowManager.hyprland;
  cfg = hypr-cfg.pyprland;
in
{
  options.wayland.windowManager.hyprland.pyprland = {
    enable = mkEnableOption "Wether to enable pyprland";

    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    assertions = [
      {
        assertion = hypr-cfg.enable == true;
        message = "Service pyprland needs hyprland to be enabled";
      }
    ];

    wayland.windowManager.hyprland.settings.exec-once = [
      "${pypr}"
    ];

    xdg.configFile."hypr/pyprland.toml".text = readFile ./pyprland.toml;
  };
}
