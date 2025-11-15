{ lib, ... }:
let
  inherit (lib) mkOption;
  inherit (lib.types) bool;
in
{
  imports = [
    ./keymap
    ./plugins
    ./settings
    ./theme
  ];

  options.programs.yazi = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };
}
