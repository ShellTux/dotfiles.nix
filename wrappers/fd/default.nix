{
  config,
  pkgs,
  wlib,
  lib,
  ...
}:
let
  inherit (lib) mkOption;
  inherit (lib.types)
    bool
    enum
    listOf
    str
    ;
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
      example = "none";
    };

    hidden = mkOption {
      type = bool;
      default = false;
      example = true;
      description = "Search hidden files and directories";
    };

    ignore = mkOption {
      type = listOf str;
      default = [
        ".git/"
        "*.bak"
      ];
      example = [ ];
      description = "List of paths that should be globally ignored.";
    };
  };

  config = {
    flags =
      if config.flavour == "none" then
        {
          "--hidden" = config.hidden;
        }
      else if config.flavour == "config1" then
        { }
      else
        null;

    flagSeparator = "=";
    package = pkgs.fd;
  };
}
