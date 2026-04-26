{ pkgs, lib, ... }:
let
  inherit (lib) mkOption;
  inherit (lib.types) str;
in
{
  imports = [
    ./none
    ./config1
  ];

  options = {
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
