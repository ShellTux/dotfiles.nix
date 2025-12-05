{
  config,
  lib,
  flake-lib,
  ...
}:
let
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool str port;
  inherit (flake-lib.caddy) genVirtualHosts;

  cfg = config.services.photoprism;
in
{
  options.services.photoprism = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };

    subdomain = mkOption {
      description = "subdomain";
      type = str;
      default = "photoprism";
    };

    reverse-proxy.port = {
      external = mkOption {
        description = "Reverse Proxy external port";
        type = port;
        default = 9907;
      };

      internal = mkOption {
        description = "Reverse Proxy internal port";
        type = port;
        default = cfg.port;
      };
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    services.photoprism = mkDefault {
      settings = {
        PHOTOPRISM_DEFAULT_LOCALE = "pt";
      };
    };

    services.caddy.virtualHosts = genVirtualHosts {
      inherit (cfg) subdomain reverse-proxy;
    };

    programs.rust-motd.settings.service_status.Photoprism = "photoprism";
  };
}
