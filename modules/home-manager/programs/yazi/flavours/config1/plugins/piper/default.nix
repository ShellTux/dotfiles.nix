{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.programs.yazi;
in
mkIf (cfg.enable && cfg.flavour == "config1") {
  programs.yazi.plugins = { inherit (pkgs.yaziPlugins) piper; };
}
