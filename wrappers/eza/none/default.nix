{ lib, config, ... }:
let
  inherit (builtins) concatStringsSep;
  inherit (lib) mkIf;
in
mkIf (config.flavour == "none") {
  flags = {
    "--across" = true;
    "--binary" = true;
    "--color" = config.color;
    "--color-scale" = concatStringsSep "," config.color-scale;
    "--git" = config.git;
    "--group-directories-first" = true;
    "--group" = true;
    "--header" = true;
    "--icons" = config.icons;
  };
  flagSeparator = "=";
}
