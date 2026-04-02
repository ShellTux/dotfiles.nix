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
  inherit (lib.types) bool package;
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

    wayland.windowManager.hyprland.settings = {
      exec-once = [
        "${pypr}"
      ];

      bind = [
        # Pypr
        "$mainMod , Z, exec, ${pypr} zoom ++0.5"
        "$mainMod SHIFT, Z, exec, ${pypr} zoom"

        "$mainMod, B, exec, ${pypr} toggle btop"
        "$mainMod, E, exec, ${pypr} toggle yazi"
        "$mainMod, M, exec, ${pypr} toggle ncmpcpp"
        "$mainMod, R, exec, ${pypr} toggle htop"
        "$mainMod, N, exec, ${pypr} toggle nvtop"
        "$mainMod, S, exec, ${pypr} toggle term"
        "$mainMod, X, exec, ${pypr} toggle qalc"

        "$mainMod, backslash, exec, ${pypr} toggle-dpms"

        "$mainMod SHIFT, apostrophe, exec, ${pypr} menu"
      ];
    };

    xdg.configFile."pypr/config.toml".text = readFile ./pyprland.toml;
  };
}
