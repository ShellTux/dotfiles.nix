{ lib, config, ... }:
let
  inherit (lib) mkIf;
in
mkIf (config.flavour == "config1") {
  flags = { };
}
