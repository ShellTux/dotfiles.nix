{ config, lib, ... }:
let
  inherit (lib) mkIf;

  cfg = config.services.openssh;
in
{
  config = mkIf (cfg.enable && !cfg.disableModule) {
  };
}
