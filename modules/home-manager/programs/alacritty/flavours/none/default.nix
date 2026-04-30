{ config, lib, ... }:
let
  inherit (lib) mkIf;

  cfg = config.programs.alacritty;
in
mkIf (cfg.enable && cfg.flavour == "none") { }
