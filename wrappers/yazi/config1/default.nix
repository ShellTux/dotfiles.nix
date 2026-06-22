{
  lib,
  config,
  pkgs,
  ...
}:
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
    theme = toml2nix ./theme.toml;
    yazi = toml2nix ./yazi.toml;
  };

  constructFiles."init.lua" = {
    content = readFile ./init.lua;
    relPath = "yazi-config/init.lua";
  };

  plugins = {
    inherit (pkgs.yaziPlugins)
      bypass
      git
      githead
      glow
      gvfs
      lsar
      office
      ouch
      piper
      smart-paste
      sshfs
      ;
  };

  runtimePkgs = [
    pkgs.exiftool
    pkgs.imv
    pkgs.mpv
    pkgs.unar
  ];
}
