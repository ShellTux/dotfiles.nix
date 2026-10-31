{
  config,
  lib,
  lib',
  pkgs,
  ...
}:
let
  inherit (builtins) elem toString;
  inherit (lib)
    mkOption
    mkIf
    mkDefault
    removeSuffix
    ;
  inherit (lib.types) bool;
  inherit (lib'.flake.networking) mkSiteOptions;

  # https://grafana.com/grafana/dashboards/1860
  node-exporter-full = pkgs.fetchurl {
    name = "node-dashboard-full";
    url = "https://grafana.com/api/dashboards/1860/revisions/42/download";
    hash = "sha256-QWEhVuEj0XH+ZqRDYf4yKA0Sk1cdb9iZl1byI4geDm4=";
    recursiveHash = true;
    postFetch = ''
      mv "$out" temp
      mkdir -p "$out"
      mv temp "$out/node-dashboard-full.json";
    '';
  };

  cfg = config.services.grafana;
in
{
  options.services.grafana = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };

    site = mkSiteOptions {
      subdomain = "grafana";
      inherit (config.networking) fqdnOrHostName localFqdn;
      description = "Grafana is a visualization tool for creating real-time monitoring dashboards from various data sources.";
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    services = {
      grafana = {
        declarativePlugins = [
          pkgs.grafanaPlugins.grafana-clock-panel
          pkgs.grafanaPlugins.grafana-github-datasource
          pkgs.grafanaPlugins.grafana-piechart-panel
          pkgs.grafanaPlugins.influxdb
          pkgs.grafanaPlugins.marcusolsson-calendar-panel
          pkgs.grafanaPlugins.marcusolsson-csv-datasource
          pkgs.grafanaPlugins.marcusolsson-json-datasource
          pkgs.grafanaPlugins.prometheus
        ];

        settings = {
          security.secret_key = "$__file{${config.sops.secrets."grafana/secret-key".path}}";

          server = {
            enable_gzip = mkDefault true;
            http_port = mkDefault 50854;
          };
        };

        provision = {
          enable = true;

          datasources.settings.datasources = [
            {
              name = "Prometheus";
              isDefault = true;
              type = "prometheus";
              url = "http://127.0.0.1:${toString config.services.prometheus.port}";
            }
          ];

          dashboards.settings.providers = [
            {
              name = "Node Exporter Full";
              options.path = node-exporter-full;
            }
          ];
        };
      };

      prometheus = {
        enable = true;

        scrapeConfigs = [
          {
            job_name = "${config.networking.hostName}-prometheus";
            scrape_interval = "10s";
            static_configs = [
              {
                targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.node.port}" ];
              }
            ];
          }
        ];

        exporters = {
          node = {
            enable = true;
            enabledCollectors = [
              "processes"
              "systemd"
            ];
          };
        };
      };

      caddy.virtualHosts = {
        "${cfg.site.fqdn}" = mkIf (elem "public" cfg.site.exposure) {
          extraConfig = ''
            import tls-public
            import encoding
            import coraza
            import reverse-proxy 127.0.0.1:${toString cfg.settings.server.http_port}
          '';
        };

        "${cfg.site.localFqdn}" = mkIf (elem "local" cfg.site.exposure) {
          extraConfig = ''
            import tls-local
            import encoding
            import reverse-proxy 127.0.0.1:${toString cfg.settings.server.http_port}
          '';
        };
      };

      homepage-dashboard.service-templates.grafana = {
        display = "Grafana";
        inherit (cfg.site)
          href
          ping
          siteMonitor
          description
          ;
        icon = "grafana.png";
      };
    };

    programs.rust-motd.settings.service_status.Grafana =
      removeSuffix ".service" config.systemd.services.grafana.name;

    sops.secrets."grafana/secret-key" = {
      owner = "grafana";
      group = "grafana";
      restartUnits = [ "grafana.service" ];
    };
  };
}
