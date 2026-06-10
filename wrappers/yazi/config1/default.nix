{
  lib,
  config,
  pkgs,
  ...
}@inputs:
let
  inherit (builtins) readFile fromTOML;
  inherit (lib) mkIf pipe;

  toml2nix =
    path:
    pipe path [
      readFile
      fromTOML
    ];
in
mkIf (config.flavour == "config1") {
  settings = {
    keymap = toml2nix ./keymap.toml;
    yazi = toml2nix ./yazi.toml;
  };

  runtimePkgs = [
    pkgs.exiftool
    pkgs.imv
    pkgs.mpv
    pkgs.unar
  ];
}
