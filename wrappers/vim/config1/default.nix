{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (builtins) readFile;
  inherit (lib) mkIf;
  inherit (pkgs) vimPlugins;
in
mkIf (config.flavour == "config1") {
  plugins = [
    vimPlugins.auto-pairs
    vimPlugins.vim-airline
  ];

  vimrc = readFile ./vimrc.vim;
}
