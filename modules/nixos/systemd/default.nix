{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption mkIf mkForce;
  inherit (lib.types) bool;

  cfg = config.systemd;
in
{
  options.systemd = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (!cfg.disableModule) {
    # https://github.com/NixOS/nixpkgs/security/advisories/GHSA-m7pq-h9p4-8rr4
    systemd.shutdownRamfs.enable = mkForce false;
  };
}
