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
    types
    ;
  inherit (lib.types) bool;
  inherit (lib'.flake.networking) mkSiteOptions;
  inherit (config.networking) fqdnOrHostName;

  cfg = config.services.homepage-dashboard;
in
{
  options.services.homepage-dashboard = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };

    service-templates = mkOption {
      description = "Reusable Homepage Dashboard service templates.";
      type = types.attrsOf types.anything;
      default = { };
    };

    site = mkSiteOptions {
      subdomain = "home";
      inherit (config.networking) fqdnOrHostName localFqdn;
      description = "Homepage dashboard";
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    services.homepage-dashboard = {
      allowedHosts = "*";

      bookmarks = mkDefault [
        {
          Developer = [
            {
              Github = [
                {
                  abbr = "GH";
                  href = "https://github.com/";
                }
              ];
            }
          ];
        }
        {
          Entertainment = [
            {
              YouTube = [
                {
                  abbr = "YT";
                  href = "https://youtube.com/";
                }
              ];
            }
          ];
        }
      ];

      widgets = mkDefault [
        {
          resources = {
            cpu = true;
            disk = "/";
            memory = true;
          };
        }
        {
          search = {
            provider = "duckduckgo";
            target = "_blank";
          };
        }
      ];

      service-templates = {
        noticias = {
          display = "Notícias ao Minuto - Última Hora";
          widget = {
            url = "https://www.noticiasaominuto.com/rss/ultima-hora";
            type = "feed";
            layout = "grid";
            maxItems = 8;
          };
        };

        sporting = {
          display = "Sporting";
          widget = {
            url = "https://www.sporting.pt/pt/rss/noticias.xml";
            type = "feed";
            layout = "list";
            maxItems = 8;
          };
        };

        nasa-feed = {
          display = "NASA Image of the Day";
          widget = {
            url = "https://www.nasa.gov/feeds/iotd-feed/";
            type = "feed";
            layout = "grid";
            maxItems = 8;
          };
        };

        last-cves = {
          display = "Últimos CVE's graves";
          widget = {
            url = "https://cvefeed.io/rssfeed/severity/high.xml";
            type = "feed";
            layout = "list";
            maxItems = 20;
          };
        };
      };
    };

    programs.rust-motd.settings.service_status.Homepage =
      removeSuffix ".service" config.systemd.services.homepage-dashboard.name;

    services = {
      authelia.instances."${fqdnOrHostName}".settings.access_control.rules = [
        {
          inherit (cfg.site) domain;
          policy = "one_factor";
        }
      ];

      caddy.virtualHosts = {
        "${cfg.site.fqdn}" = mkIf (elem "public" cfg.site.exposure) {
          extraConfig = ''
            import tls-public
            import encoding
            import coraza
            import reverse-proxy 127.0.0.1:${toString cfg.listenPort}
          '';
        };

        "${cfg.site.localFqdn}" = mkIf (elem "local" cfg.site.exposure) {
          extraConfig = ''
            import tls-local
            import encoding
            import reverse-proxy 127.0.0.1:${toString cfg.listenPort}
          '';
        };
      };
    };
  };
}
