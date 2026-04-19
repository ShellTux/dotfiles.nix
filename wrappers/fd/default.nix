{ pkgs, lib, ... }:
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
    flagSeparator = "=";
    package = pkgs.fd;
  };
}
