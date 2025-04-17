{
  lib,
  ...
}:
let
  inherit (lib) mkOption mkDefault;
  inherit (lib.types) bool;
in
{
  options.nix.gc = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config.nix.gc = {
    automatic = mkDefault true;
    dates = mkDefault "00:00";
    options = mkDefault "--delete-older-than 7d";
  };
}
