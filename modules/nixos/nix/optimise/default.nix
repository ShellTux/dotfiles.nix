{
  lib,
  ...
}:
let
  inherit (lib) mkOption mkDefault;
  inherit (lib.types) bool;
in
{
  options.nix.optimise = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config.nix.optimise = {
    automatic = mkDefault true;
    dates = mkDefault [
      "12:00"
      "00:00"
    ];
  };
}
