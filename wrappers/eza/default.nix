{
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) mkOption;
  inherit (lib.types) bool enum listOf;
in
{
  imports = [
    ./none
    ./config1
  ];

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

    git = mkOption {
      type = bool;
      default = true;
      example = false;
      description = "List  each  file’s Git status, if tracked";
    };

    icons = mkOption {
      type = enum [
        "always"
        "automatic"
        "auto"
        "never"
      ];
      default = "auto";
      example = "never";
      description = "Display icons next to file names";
    };

    color = mkOption {
      type = enum [
        "always"
        "automatic"
        "auto"
        "never"
      ];
      default = "auto";
      example = "never";
      description = "When to use terminal colours";
    };

    color-scale = mkOption {
      type = listOf (enum [
        "age"
        "all"
        "size"
      ]);
      default = [ "all" ];
      example = [
        "age"
        "size"
      ];
      description = "highlight levels of field distinctly";
    };
  };

  config = {
    package = pkgs.eza;
  };
}
