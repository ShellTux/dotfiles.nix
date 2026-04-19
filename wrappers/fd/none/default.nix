{ lib, config, ... }:
let
  inherit (lib) mkIf;
in
mkIf (config.flavour == "none") {
  flags = {
    "--hidden" = config.hidden;
  };
}
