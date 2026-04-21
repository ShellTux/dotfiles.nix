{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkDefault;
in
mkIf (config.flavour == "config1") {
  extraPackages = [ pkgs.jetbrains-mono ];

  settings = {
    font = "JetBrains Mono 14";
    modes = "window,run,ssh,drun,calc,emoji";
    location = 0;
    xoffset = 0;
    yoffset = 0;
    show-icons = true;
  };

  theme = mkDefault "Arc-Dark";

  plugins = [
    pkgs.rofi-bluetooth
    pkgs.rofi-calc
    pkgs.rofi-emoji
    pkgs.rofimoji
    pkgs.rofi-mpd
    pkgs.rofi-network-manager
    pkgs.rofi-pass
    pkgs.rofi-power-menu
    pkgs.rofi-rbw
    pkgs.rofi-screenshot
    pkgs.rofi-top
    pkgs.rofi-vpn
  ];
}
