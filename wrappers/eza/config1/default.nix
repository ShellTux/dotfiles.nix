{ lib, config, ... }:
let
  inherit (lib) mkIf;
in
mkIf (config.flavour == "config1") {
  flags = {
    "--across" = true;
    "--binary" = true;
    "--color" = "auto";
    "--color-scale" = "all";
    "--git" = true;
    "--group-directories-first" = true;
    "--group" = true;
    "--header" = true;
    "--icons" = "auto";
  };
  flagSeparator = "=";
}
