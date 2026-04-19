{ pkgs, lib, ... }:
let
  inherit (lib) mkOption;
  inherit (lib.types) enum;
in
{
  imports = [
    # Flavours
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
  };

  config = {
    package = pkgs.bat;
  };
}
