{
  config,
  lib,
  pkgs,
  flake-lib,
  ...
}:
let
  inherit (builtins) toString;
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool port str;
  inherit (flake-lib.caddy) genVirtualHosts;

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

    subdomain = mkOption {
      description = "subdomain";
      type = str;
      default = "grafana";
    };

    reverse-proxy.port = {
      external = mkOption {
        description = "Reverse Proxy external port";
        type = port;
        default = 9915;
      };

      internal = mkOption {
        description = "Reverse Proxy internal port";
        type = port;
        default = cfg.settings.server.http_port;
      };
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    services.grafana = {
      declarativePlugins = [ pkgs.grafanaPlugins.grafana-piechart-panel ];

      settings.server = {
        enable_gzip = mkDefault true;
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

    services = {
      prometheus = {
        enable = true;
        exporters = {
          node = {
            enable = true;
            enabledCollectors = [
              "disable-defaults"
              "cpu"
              "diskstats"
              "filesystem"
              "meminfo"
              "netdev"
              "processes"
              "systemd"
              "uname"
            ];
          };
        };
      };

      caddy.virtualHosts = genVirtualHosts {
        inherit (cfg) subdomain reverse-proxy;
      };
    };

    programs.rust-motd.settings.service_status.Grafana = "grafana";
  };
}
