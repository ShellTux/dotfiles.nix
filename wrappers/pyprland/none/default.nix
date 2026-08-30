{ lib, config, ... }:
let
  inherit (lib) mkIf;
in
mkIf (config.flavour == "none") { }
