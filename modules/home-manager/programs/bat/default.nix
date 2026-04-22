{ lib', ... }:
let
  inherit (lib'.flake) mkFlavourOption dirs;
in
{
  imports = dirs ./flavours;

  options.programs.bat.flavour = mkFlavourOption ./flavours "config1";
}
