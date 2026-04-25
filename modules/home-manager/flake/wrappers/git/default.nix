{ config, lib, ... }:
let
  inherit (lib) mkIf;

  cfg = config.flake.wrappers.git;
in
mkIf cfg.enable {
  home.packages = [ cfg.package ];
}
