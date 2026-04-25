{ config, lib, ... }:
let
  inherit (lib) mkIf;

  cfg = config.flake.wrappers.bat;
in
mkIf cfg.enable {
  home.packages = [ cfg.package ];
}
