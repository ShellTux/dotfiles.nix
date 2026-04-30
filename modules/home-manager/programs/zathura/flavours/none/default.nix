{ config, lib, ... }:
let
  inherit (lib) mkIf;

  cfg = config.programs.zathura;
in
mkIf (cfg.enable && cfg.flavour == "none") { }
