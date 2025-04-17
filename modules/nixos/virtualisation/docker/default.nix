{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkOption
    mkIf
    mkDefault
    mkForce
    ;
  inherit (lib.types) bool;

  cfg = config.virtualisation.docker;
in
{
  options.virtualisation.docker = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    virtualisation.docker = mkDefault {
      enableOnBoot = false;

      autoPrune = {
        enable = true;
        dates = "quarterly";
      };

      rootless.enable = mkForce false;
    };

    environment.systemPackages = [
      pkgs.docker-client
    ];
  };
}
