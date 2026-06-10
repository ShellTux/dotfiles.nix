{ pkgs, ... }:
{
  imports = [
    ./none
    ./config1
  ];

  config.runtimePkgs = [
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
