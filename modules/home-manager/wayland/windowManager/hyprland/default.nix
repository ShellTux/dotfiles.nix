{
  self',
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (builtins) readFile filter;
  inherit (lib) mkOption mkIf optional;
  inherit (lib.types)
    bool
    listOf
    package
    nullOr
    ;

  cfg = config.wayland.windowManager.hyprland;
in
{
  imports = [
    ./bar
    ./pyprland
    ./settings
    ./systemd
  ];

  options.wayland.windowManager.hyprland = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };

    extraPackages = mkOption {
      description = "Useful extra packages to install along side with hyprland";
      type = listOf package;
      default = [
        self'.packages.kitty
        pkgs.libnotify
        pkgs.pavucontrol
        pkgs.pw-volume
        pkgs.pwvucontrol
        pkgs.qpwgraph
        pkgs.wofi
      ]
      ++ [
        # Pyprland
        self'.packages.btop
        self'.packages.htop
        pkgs.hyprpicker
        pkgs.hyprshot
        pkgs.libqalculate
        pkgs.pyprland
        pkgs.satty
      ]
      ++ optional (!config.programs.yazi.enable) self'.packages.yazi
      ++ [
        self'.packages.ncmpcpp
        self'.packages.brightness
        self'.packages.volume
      ];
      example = [ ];
    };

    bar = {
      waybar = mkOption {
        description = "Which waybar package to use. (Leave null to disable)";
        type = nullOr package;
        default = null;
        example = pkgs.waybar;
      };

      noctalia-shell = mkOption {
        description = "Which noctalia-shell package to use. (Leave null to disable)";
        type = nullOr package;
        default = null;
        example = pkgs.noctalia-shell;
      };
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    wayland.windowManager.hyprland = {
      extraConfig = readFile ./hyprland.conf;

      xwayland.enable = true;
    };

    home.packages = filter (pkg: pkg != null) (
      cfg.extraPackages
      ++ [
        cfg.bar.noctalia-shell
        cfg.bar.waybar
      ]
    );
  };
}
