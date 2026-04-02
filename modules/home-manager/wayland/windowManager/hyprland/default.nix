{
  self,
  config,
  lib,
  pkgs,
  system,
  ...
}:
let
  inherit (builtins) readFile filter;
  inherit (lib)
    mkOption
    mkIf
    pipe
    ;
  inherit (lib.types)
    bool
    listOf
    package
    nullOr
    ;
  inherit (self.packages.${system}) volume brightness;

  ncmpcpp = config.programs.ncmpcpp.package;

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

    bar = {
      waybar = mkOption {
        description = "Which waybar package to use. (Leave null to disable waybar)";
        type = nullOr package;
        default = null;
        example = pkgs.waybar;
      };

      noctalia-shell = mkOption {
        description = "Which noctalia-shell package";
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

    home.packages =
      pipe
        (
          cfg.extraPackages
          ++ [
            cfg.bar.noctalia-shell
            cfg.bar.waybar
          ]
        )
        [
          (filter (pkg: pkg != null))
        ];
  };
}
