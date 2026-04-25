{ config, lib, ... }:
let
  inherit (lib) mkIf;

  cfg = config.flake.wrappers.fd;
in
mkIf cfg.enable {
  home.packages = [ cfg.package ];
}
