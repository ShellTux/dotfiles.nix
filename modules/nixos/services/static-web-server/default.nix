{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool;

  cfg = config.services.static-web-server;
in
{
  options.services.static-web-server = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    services.static-web-server = mkDefault {
      root = ./templates/default;
    };

    networking.firewall.allowedTCPPorts = mkDefault [ 8787 ];
  };
}
