{ config, lib, ... }:
let
  inherit (lib) mkIf;

  cfg = config.flake.wrappers.yt-dlp;
in
mkIf cfg.enable {
  home.packages = [ cfg.package ];
}
