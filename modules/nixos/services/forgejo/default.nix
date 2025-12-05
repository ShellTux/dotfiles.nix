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

  cfg = config.services.forgejo;
in
{
  options.services.forgejo = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };

    subdomain = mkOption {
      description = "subdomain";
      type = str;
      default = "forgejo";
    };

    reverse-proxy.port = {
      external = mkOption {
        description = "Reverse Proxy external port";
        type = port;
        default = 9910;
      };

      internal = mkOption {
        description = "Reverse Proxy internal port";
        type = port;
        default = 50610;
      };
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    services.forgejo = {
      lfs.enable = true;

      settings = {
        server = {
          HTTP_PORT = cfg.reverse-proxy.port.internal;
          ROOT_URL = "https://${cfg.subdomain}.${config.server.domain}:${toString cfg.reverse-proxy.port.external}";
        };
        # domain = config.server.domain;
        # session.COOKIE_SECURE = true;
      };
    };

    services.caddy.virtualHosts = genVirtualHosts {
      inherit (cfg) subdomain reverse-proxy;
    };

    programs.rust-motd.settings.service_status.Forgejo = "forgejo";
  };
}
