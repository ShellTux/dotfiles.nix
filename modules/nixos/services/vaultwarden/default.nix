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

  cfg = config.services.vaultwarden;
in
{
  options.services.vaultwarden = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };

    subdomain = mkOption {
      description = "Subdomain";
      type = str;
      default = "vaultwarden";
    };

    reverse-proxy.port = {
      external = mkOption {
        description = "Reverse Proxy external port";
        type = port;
        default = 9903;
      };

      internal = mkOption {
        description = "Reverse Proxy internal port";
        type = port;
        default = cfg.config.ROCKET_PORT;
      };
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    services.vaultwarden = {
      backupDir = "/var/backup/vaultwarden";
      config = {
        DOMAIN = "https://${cfg.subdomain}.${config.server.domain}";
        ROCKET_ADDRESS = "127.0.0.1";
        ROCKET_PORT = 8222;
      };
    };

    programs.rust-motd.settings.service_status.Vaultwarden = "vaultwarden";

    services.caddy.virtualHosts = genVirtualHosts {
      inherit (cfg) subdomain reverse-proxy;
    };
  };
}
