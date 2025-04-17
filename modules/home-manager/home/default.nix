{
  lib,
  ...
}:
let
  inherit (lib) mkOption;
  inherit (lib.types) listOf str bool;
in
{
  imports = [
    ./sessionVariables
    ./shellAliases
  ];

  options.home = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };

    disableAliases = mkOption {
      description = "Which aliases to disable";
      type = listOf str;
      default = [ ];
      example = [ "progress" ];
    };

    disableVariables = mkOption {
      description = "Which variables to disable";
      type = listOf str;
      default = [ ];
      example = [ "MANPAGER" ];
    };
  };
}
