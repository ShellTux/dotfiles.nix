{
  config,
  pkgs,
  wlib,
  lib,
  ...
}:
let
  inherit (builtins) concatStringsSep;
  inherit (lib) mkOption mkDefault;
  inherit (lib.types) bool enum listOf;
in
{
  imports = [ wlib.modules.default ];

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
    flags =
      if config.flavour == "none" then
        {
          "--across" = true;
          "--binary" = true;
          "--color" = config.color;
          "--color-scale" = concatStringsSep "," config.color-scale;
          "--git" = config.git;
          "--group-directories-first" = true;
          "--group" = true;
          "--header" = true;
          "--icons" = config.icons;
        }
      else if config.flavour == "config1" then
        {
          "--across" = true;
          "--binary" = true;
          "--color" = "auto";
          "--color-scale" = "all";
          "--git" = true;
          "--group-directories-first" = true;
          "--group" = true;
          "--header" = true;
          "--icons" = "auto";
        }
      else
        null;
    flagSeparator = "=";
    package = pkgs.eza;
  };
}
