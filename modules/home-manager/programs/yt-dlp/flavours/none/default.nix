{ config, lib, ... }:
let
  inherit (lib) mkIf;

  cfg = config.programs.yt-dlp;
in
mkIf (cfg.enable && cfg.flavour == "none") { }
