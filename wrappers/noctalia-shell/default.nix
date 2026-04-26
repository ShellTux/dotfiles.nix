{ pkgs, ... }:
{
  imports = [
    ./none
    ./config1
  ];

  config.extraPackages = [
    pkgs.curl
    pkgs.grim
    pkgs.imagemagick
    pkgs.kitty
    pkgs.noctalia-shell
    pkgs.quickshell
    pkgs.slurp
    pkgs.wl-clipboard
    pkgs.zbar
  ];
}
