{
  config,
  lib,
  flake-lib,
  ...
}:
let
  inherit (lib) mkOption mkIf;
  inherit (lib.types) bool str port;
  inherit (flake-lib.caddy) genVirtualHosts;

  cfg = config.services.changedetection-io;
in
{
  options.services.changedetection-io = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };

    subdomain = mkOption {
      description = "subdomain";
      type = str;
      default = "changedetection";
    };

    reverse-proxy.port = {
      external = mkOption {
        description = "Reverse Proxy external port";
        type = port;
        default = 9913;
      };

      internal = mkOption {
        description = "Reverse Proxy internal port";
        type = port;
        default = cfg.port;
      };
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    services.changedetection-io = { };

    services.caddy.virtualHosts = genVirtualHosts {
      inherit (cfg) subdomain reverse-proxy;
    };

    programs.rust-motd.settings.service_status.ChangeDetectionIO = "changedetection-io";
  };
}
