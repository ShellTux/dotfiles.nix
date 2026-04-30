{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.programs.yazi;
in
mkIf (cfg.enable && cfg.flavour == "config1") {
  programs.yazi.theme = { };
}
