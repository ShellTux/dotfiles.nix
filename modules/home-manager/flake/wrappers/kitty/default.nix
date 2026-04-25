{ config, lib, ... }:
let
  inherit (lib) mkIf;

  cfg = config.flake.wrappers.kitty;
in
mkIf cfg.enable {
  home.packages = [ cfg.package ];
}
