{
  config,
  pkgs,
  wlib,
  lib,
  ...
}:
let
  inherit (builtins) readFile;
  inherit (lib) mkOption;
  inherit (lib.types) enum;
in
{
  imports = [ wlib.wrapperModules.vim ];

  options = {
    flavour = mkOption {
      type = enum [
        "none"
        "config1"
      ];
      default = "config1";
      description = ''
        Which flavour of configuration to pick:
        - `none`: No configuration, allowed to change
        - `config1`: Not allowed to change.
      '';
    };
  };

  config = {
    plugins =
      let
        inherit (pkgs) vimPlugins;
      in
      if config.flavour == "none" then
        [ ]
      else if config.flavour == "config1" then
        [
          vimPlugins.auto-pairs
          vimPlugins.vim-airline
        ]
      else
        null;

    vimrc =
      if config.flavour == "none" then
        ""
      else if config.flavour == "config1" then
        readFile ./vimrc
      else
        null;
  };
}
