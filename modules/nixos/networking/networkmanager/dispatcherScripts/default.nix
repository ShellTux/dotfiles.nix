{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (builtins) readFile;
  inherit (lib) mkIf mkDefault;

  cfg = config.networking.networkmanager;
  packages = pkgs // {
    inherit readFile;
  };
in
{
  config = mkIf (cfg.enable && !cfg.disableModule) {
    networking.networkmanager.dispatcherScripts = mkDefault [
      (import ./09-timezone.nix packages)
    ];
  };
}
