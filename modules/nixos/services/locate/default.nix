{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption mkIf;
  inherit (lib.types) bool listOf str;

  cfg = config.services.locate;
in
{
  options.services.locate = {
    disableModule = mkOption {
      description = "Whether to disable locate configuration through NixOS Module";
      type = bool;
      default = false;
    };

    # TODO: append to default prunePaths
    extraPrunePaths = mkOption {
      description = "Extra paths to prune from locate.";
      type = listOf str;
      default = [ ];
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    services.locate = {
      package = pkgs.plocate;
      prunePaths = [
        "/tmp"
        "/var/tmp"
        "/var/cache"
        "/var/lock"
        "/var/run"
        "/var/spool"
        "/nix/store"
        "/nix/var/log/nix"
      ] ++ cfg.extraPrunePaths;
    };
  };
}
