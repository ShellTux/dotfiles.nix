{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (builtins) toJSON toFile;
  inherit (lib)
    mkOption
    mkEnableOption
    mkIf
    getExe
    types
    pipe
    ;

  systemd-script = getExe (pkgs.callPackage ./script { });

  speedtest-dashboard =
    pipe
      {
        annotations = {
          list = [
            {
              builtIn = 1;
              datasource = {
                type = "datasource";
                uid = "grafana";
              };
              enable = true;
              hide = true;
              iconColor = "rgba(0, 211, 255, 1)";
              name = "Annotations & Alerts";
              target = {
                limit = 100;
                matchAny = false;
                tags = [ ];
                type = "dashboard";
              };
              type = "dashboard";
            }
          ];
        };

        editable = true;
        fiscalYearStartMonth = 0;
        graphTooltip = 1;
        schemaVersion = 41;
        tags = [
          "network"
          "speedtest"
        ];
        timezone = "browser";
        title = "Internet Speed";
        version = 1;

        templating = {
          list = [
            {
              current = { };
              includeAll = false;
              label = "Datasource";
              name = "ds_prometheus";
              options = [ ];
              query = "prometheus";
              refresh = 1;
              regex = "";
              type = "datasource";
            }
          ];
        };

        time = {
          from = "now-30d";
          to = "now";
        };

        panels = [
          {
            datasource = {
              type = "prometheus";
              uid = "\${ds_prometheus}";
            };
            fieldConfig = {
              defaults = {
                color.mode = "thresholds";
                unit = "Mbits";
              };
              overrides = [ ];
            };
            gridPos = {
              h = 5;
              w = 6;
              x = 0;
              y = 0;
            };
            id = 1;
            options = {
              colorMode = "value";
              graphMode = "area";
              justifyMode = "auto";
              orientation = "auto";
              reduceOptions = {
                calcs = [ "lastNotNull" ];
                fields = "";
                values = false;
              };
              textMode = "auto";
            };
            targets = [
              {
                editorMode = "code";
                expr = "speedtest_download_bits_per_second / 1e6";
                instant = true;
                range = false;
                refId = "A";
              }
            ];
            title = "Download";
            type = "stat";
          }

          {
            datasource = {
              type = "prometheus";
              uid = "\${ds_prometheus}";
            };
            fieldConfig = {
              defaults = {
                color.mode = "thresholds";
                unit = "Mbits";
              };
              overrides = [ ];
            };
            gridPos = {
              h = 5;
              w = 6;
              x = 6;
              y = 0;
            };
            id = 2;
            options = {
              colorMode = "value";
              graphMode = "area";
              reduceOptions = {
                calcs = [ "lastNotNull" ];
                fields = "";
                values = false;
              };
            };
            targets = [
              {
                editorMode = "code";
                expr = "speedtest_upload_bits_per_second / 1e6";
                instant = true;
                range = false;
                refId = "A";
              }
            ];
            title = "Upload";
            type = "stat";
          }

          {
            datasource = {
              type = "prometheus";
              uid = "\${ds_prometheus}";
            };
            fieldConfig = {
              defaults = {
                color.mode = "thresholds";
                unit = "ms";
              };
              overrides = [ ];
            };
            gridPos = {
              h = 5;
              w = 6;
              x = 12;
              y = 0;
            };
            id = 3;
            options = {
              colorMode = "value";
              graphMode = "none";
              reduceOptions = {
                calcs = [ "lastNotNull" ];
                fields = "";
                values = false;
              };
            };
            targets = [
              {
                editorMode = "code";
                expr = "speedtest_ping_milliseconds";
                instant = true;
                range = false;
                refId = "A";
              }
            ];
            title = "Ping";
            type = "stat";
          }

          {
            datasource = {
              type = "prometheus";
              uid = "\${ds_prometheus}";
            };
            fieldConfig = {
              defaults.unit = "s";
              overrides = [ ];
            };
            gridPos = {
              h = 5;
              w = 6;
              x = 18;
              y = 0;
            };
            id = 4;
            options = {
              colorMode = "none";
              graphMode = "none";
              reduceOptions = {
                calcs = [ "lastNotNull" ];
                fields = "";
                values = false;
              };
            };
            targets = [
              {
                editorMode = "code";
                expr = "time() - speedtest_last_run_timestamp";
                instant = true;
                range = false;
                refId = "A";
              }
            ];
            title = "Last Run Age";
            type = "stat";
          }

          {
            datasource = {
              type = "prometheus";
              uid = "\${ds_prometheus}";
            };
            fieldConfig = {
              defaults = {
                color.mode = "palette-classic";
                unit = "Mbits";
              };
              overrides = [ ];
            };
            gridPos = {
              h = 10;
              w = 24;
              x = 0;
              y = 5;
            };
            id = 5;
            options = {
              legend = {
                calcs = [
                  "min"
                  "mean"
                  "max"
                ];
                displayMode = "table";
                placement = "bottom";
                showLegend = true;
              };
              tooltip = {
                mode = "multi";
                sort = "none";
              };
            };
            targets = [
              {
                editorMode = "code";
                expr = "speedtest_download_bits_per_second / 1e6";
                legendFormat = "Download";
                range = true;
                refId = "A";
              }
              {
                editorMode = "code";
                expr = "speedtest_upload_bits_per_second / 1e6";
                legendFormat = "Upload";
                range = true;
                refId = "B";
              }
            ];
            title = "Bandwidth History";
            type = "timeseries";
          }

          {
            datasource = {
              type = "prometheus";
              uid = "\${ds_prometheus}";
            };
            fieldConfig = {
              defaults = {
                color.mode = "palette-classic";
                unit = "ms";
              };
              overrides = [ ];
            };
            gridPos = {
              h = 8;
              w = 12;
              x = 0;
              y = 15;
            };
            id = 6;
            options = {
              legend = {
                calcs = [
                  "min"
                  "mean"
                  "max"
                ];
                displayMode = "table";
                placement = "bottom";
                showLegend = true;
              };
            };
            targets = [
              {
                editorMode = "code";
                expr = "speedtest_ping_milliseconds";
                legendFormat = "Ping";
                range = true;
                refId = "A";
              }
            ];
            title = "Ping History";
            type = "timeseries";
          }

          {
            datasource = {
              type = "prometheus";
              uid = "\${ds_prometheus}";
            };
            fieldConfig = {
              defaults.unit = "none";
              overrides = [ ];
            };
            gridPos = {
              h = 8;
              w = 12;
              x = 12;
              y = 15;
            };
            id = 7;
            options = {
              showHeader = true;
            };
            targets = [
              {
                editorMode = "code";
                expr = "speedtest_server_info";
                format = "table";
                instant = true;
                refId = "A";
              }
            ];
            title = "Server Information";
            type = "table";
          }
        ];
      }
      [
        toJSON
        (pkgs.writeText "speedtest.json")
      ];

  cfg = config.services.grafana;
in
{
  options.services.grafana.speedtest-exporter = {
    enable = mkEnableOption "Whether to enable speedtest reports";

    intervalSeconds = mkOption {
      type = types.int;
      default = 3600;
    };

    initialDelaySeconds = mkOption {
      type = types.int;
      default = 30;
    };

    metricsDir = mkOption {
      type = types.str;
      default = "/var/lib/prometheus-node-exporter-text-files";
    };
  };

  config = mkIf (cfg.enable && cfg.speedtest-exporter.enable && !cfg.disableModule) {

    systemd = {
      services.speedtest-exporter = {
        description = "Run periodic speed tests and export metrics";

        after = [
          "network-online.target"
          "prometheus-node-exporter.service"
        ];

        wants = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];

        environment = {
          METRICS_DIR = cfg.speedtest-exporter.metricsDir;
          INITIAL_DELAY_SECONDS = toString cfg.speedtest-exporter.initialDelaySeconds;
          INTERVAL_SECONDS = toString cfg.speedtest-exporter.intervalSeconds;
        };

        serviceConfig = {
          Type = "simple";
          ExecStart = systemd-script;
          Restart = "always";
          RestartSec = "60s";
        };
      };

      # TODO: only permissions for prometheus
      tmpfiles.rules = [
        "d ${cfg.speedtest-exporter.metricsDir} 0755 root root -"
        "L+ /var/lib/grafana/dashboards/speedtest.json - - - - ${speedtest-dashboard}"
      ];

    };

    services = {
      grafana.provision.dashboards.settings.providers = [
        {
          name = "Speedtest";
          options.path = speedtest-dashboard;
        }
      ];

      prometheus.exporters.node.extraFlags = [
        "--collector.textfile.directory=${cfg.speedtest-exporter.metricsDir}"
      ];
    };
  };
}
