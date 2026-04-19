{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf;
in
mkIf (config.flavour == "none") { }
