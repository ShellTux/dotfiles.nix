{
  lib,
  config,
  pkgs,
  ...
}@inputs:
let
  inherit (lib) mkIf;
in
mkIf (config.flavour == "config1") {
  settings.yazi = import ./settings { inherit inputs; };

  extraPackages = [
    pkgs.exiftool
    pkgs.imv
    pkgs.mpv
    pkgs.unar
  ];
}
