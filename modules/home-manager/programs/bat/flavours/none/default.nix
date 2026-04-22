{ config, lib, ... }:
let
  inherit (lib) mkIf;

  cfg = config.programs.bat;
in
mkIf (cfg.enable && cfg.flavour == "none") { }
