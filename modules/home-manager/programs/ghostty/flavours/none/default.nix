{ config, lib, ... }:
let
  inherit (lib) mkIf;

  cfg = config.programs.ghostty;
in
mkIf (cfg.enable && cfg.flavour == "none") { }
