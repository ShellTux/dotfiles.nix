{ lib, ... }:
let
  inherit (lib) mkOption;
  inherit (lib.types) str;
in
{
  imports = [
    ./flavours
  ];

  options.programs.ghostty.leader-key = mkOption {
    type = str;
    default = "ctrl+space";
    example = "ctrl+b";
    description = "Ghostty leader prefix key";
  };
}
