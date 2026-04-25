{ config, lib, ... }:
let
  inherit (lib) mkIf;

  cfg = config.flake.wrappers.fastfetch;
in
mkIf cfg.enable {
  home.packages = [ cfg.package ];
}
