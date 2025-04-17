{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool;

  cfg = config.services.guix;
in
{
  options.services.guix = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    services.guix = mkDefault {
      storeDir = "/gnu/store";
      stateDir = "/gnu/var";

      gc = {
        enable = true;
        # https://guix.gnu.org/en/manual/en/html_node/Invoking-guix-gc.html
        extraArgs = [
          "--delete-generations=1m"
          "--free-space=10G"
          "--optimize"
        ];
      };
    };
  };
}
