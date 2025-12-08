{
  config,
  lib,
  flake-lib,
  ...
}:
let
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool port str;
  inherit (flake-lib.caddy) genVirtualHosts;

  cfg = config.services.wiki-js;

  inherit (cfg.settings.db) db user;
in
{
  options.services.wiki-js = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };

    subdomain = mkOption {
      description = "subdomain";
      type = str;
      default = "wikijs";
    };

    reverse-proxy.port = {
      external = mkOption {
        description = "Reverse Proxy external port";
        type = port;
        default = 9914;
      };

      internal = mkOption {
        description = "Reverse Proxy internal port";
        type = port;
        default = cfg.settings.port;
      };
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    services.wiki-js = {
      settings = {
        bindIP = mkDefault "127.0.0.1";
        port = 45226;
        db = {
          host = "/run/postgresql";
          type = "postgres";
          db = "wiki-js";
          user = "wiki-js";
        };
      };
    };

    services = {
      postgresql = {
        enable = true;
        ensureDatabases = [ db ];
        ensureUsers = [
          {
            name = user;
            ensureDBOwnership = true;
          }
        ];
      };

      caddy.virtualHosts = genVirtualHosts {
        inherit (cfg) subdomain reverse-proxy;
      };
    };

    # WARNING: make sure postgresql is the same db type as wiki-js config
    systemd.services.wiki-js = {
      requires = [ "postgresql.service" ];
      after = [ "postgresql.service" ];
    };

    programs.rust-motd.settings.service_status.WikiJS = "wiki-js";
  };
}
