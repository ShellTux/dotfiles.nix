{
  config,
  lib,
  lib',
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
  inherit (lib.types) bool package;
  inherit (lib'.flake.hyprland.lua) mkBinds;
  inherit (pkgs.stdenv.hostPlatform) system;

  hypr-cfg = config.wayland.windowManager.hyprland;
  cfg = hypr-cfg.pyprland;
  pypr = getExe' cfg.package "pypr";
in
{
  options.wayland.windowManager.hyprland.pyprland = {
    enable = mkEnableOption "Wether to enable pyprland";

    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };

    package = mkOption {
      description = "Which package of pyprland to use";
      type = package;
      default = inputs.pyprland.packages.${system}.default;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    assertions = [
      {
        assertion = hypr-cfg.enable == true;
        message = "Service pyprland needs hyprland to be enabled";
      }
    ];

    wayland.windowManager.hyprland = {
      exec-once = [
        "${pypr}"
      ];

      settings.bind = mkBinds {
        # Pypr
        "SUPER + Z".dsp.exec_cmd = [ "${pypr} zoom ++0.5" ];
        "SUPER + SHIFT + Z".dsp.exec_cmd = [ "${pypr} zoom" ];

        "SUPER + B".dsp.exec_cmd = [ "${pypr} toggle btop" ];
        "SUPER + E".dsp.exec_cmd = [ "${pypr} toggle yazi" ];
        "SUPER + M".dsp.exec_cmd = [ "${pypr} toggle ncmpcpp" ];
        "SUPER + R".dsp.exec_cmd = [ "${pypr} toggle htop" ];
        "SUPER + N".dsp.exec_cmd = [ "${pypr} toggle nvtop" ];
        "SUPER + S".dsp.exec_cmd = [ "${pypr} toggle term" ];
        "SUPER + X".dsp.exec_cmd = [ "${pypr} toggle qalc" ];

        "SUPER + backslash".dsp.exec_cmd = [ "${pypr} toggle-dpms" ];

        "SUPER + SHIFT + apostrophe".dsp.exec_cmd = [ "${pypr} menu" ];
      };
    };

    xdg.configFile."pypr/config.toml".text = readFile ./pyprland.toml;
  };
}
