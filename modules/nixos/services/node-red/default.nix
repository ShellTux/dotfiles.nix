{
  config,
  lib,
  lib',
  ...
}:
let
  inherit (builtins) elem;
  inherit (lib)
    mkOption
    mkIf
    mkDefault
    removeSuffix
    ;
  inherit (lib.types) bool;
  inherit (lib'.flake.networking) mkSiteOptions;

  cfg = config.services.node-red;
in
{
  options.services.node-red = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };

    site = mkSiteOptions {
      subdomain = "node-red";
      inherit (config.networking) fqdnOrHostName localFqdn;
      description = "Low-code programming for event-driven applications";
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    services.node-red = mkDefault { };

    services = {
      caddy.virtualHosts = mkIf (cfg.site.reverse-proxy == "caddy") {
        "${cfg.site.fqdn}" = mkIf (elem "public" cfg.site.exposure) {
          extraConfig = ''
            import tls-public
            import encoding
            import coraza
            import reverse-proxy 127.0.0.1:${toString cfg.port}
          '';
        };

        "${cfg.site.localFqdn}" = mkIf (elem "local" cfg.site.exposure) {
          extraConfig = ''
            import tls-local
            import encoding
            import reverse-proxy 127.0.0.1:${toString cfg.port}
          '';
        };
      };

      homepage-dashboard.service-templates.node-red = {
        display = "Node-RED";
        inherit (cfg.site)
          href
          ping
          siteMonitor
          description
          ;
        icon = "node-red.png";
      };
    };

    programs.rust-motd.settings.service_status.Node-RED =
      removeSuffix ".service" config.systemd.services.node-red.name;
  };
}
