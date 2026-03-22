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
    getExe'
    ;
  inherit (lib.types) bool;
  inherit (pkgs.stdenv.hostPlatform) system;

  pypr = getExe' inputs.pyprland.packages.${system}.default "pypr";

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

    xdg.configFile."pypr/config.toml".text = readFile ./pyprland.toml;
  };
}
