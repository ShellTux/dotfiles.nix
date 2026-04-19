{ config, lib, ... }:
let
  inherit (lib) mkIf;
in
mkIf (config.flavour == "config1") { }
