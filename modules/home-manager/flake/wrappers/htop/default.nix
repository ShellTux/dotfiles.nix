{ config, lib, ... }:
let
  inherit (lib) mkIf;

  cfg = config.flake.wrappers.htop;
in
mkIf cfg.enable {
  home.packages = [ cfg.package ];
}
