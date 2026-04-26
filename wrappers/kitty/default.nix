{ pkgs, lib, ... }:
let
  inherit (lib) mkOption;
  inherit (lib.types) enum str;
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

    leader = mkOption {
      type = str;
      default = "ctrl+space";
      example = "ctrl+b";
      description = "The prefix key for kitty tab and window management.";
    };
  };

  config = {
    extraPackages = [ pkgs.nerd-fonts.symbols-only ];
  };
}
