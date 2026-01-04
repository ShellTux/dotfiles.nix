{
  self,
  config,
  lib,
  pkgs,
  system,
  ...
}:
let
  inherit (builtins) readFile;
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool listOf package;
  inherit (self.packages.${system}) volume brightness;

  ncmpcpp = config.programs.ncmpcpp.package;

  cfg = config.wayland.windowManager.hyprland;
in
{
  imports = [
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
        pkgs.kitty
        pkgs.libnotify
        pkgs.pavucontrol
        pkgs.pw-volume
        pkgs.pwvucontrol
        pkgs.qpwgraph
        pkgs.wofi
      ]
      ++ [
        # Pyprland
        pkgs.btop
        pkgs.htop
        pkgs.hyprpicker
        pkgs.hyprshot
        pkgs.libqalculate
        pkgs.pyprland
        pkgs.satty
      ]
      ++ (if config.programs.yazi.enable then [ ] else [ pkgs.yazi ])
      ++ [
        ncmpcpp
        brightness
        volume
      ];
      example = [ ];
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    wayland.windowManager.hyprland = {
      extraConfig = readFile ./hyprland.conf;

      xwayland.enable = true;
    };

    home.packages = cfg.extraPackages;

    programs.hyprlock.enable = mkDefault true;
    services.hypridle.enable = mkDefault true;
  };
}
