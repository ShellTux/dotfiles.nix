{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool str;

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

      default = "vaultwarden.${config.server.domain}";
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    services.vaultwarden = mkDefault {
      backupDir = "/var/backup/vaultwarden";
      config = {
        DOMAIN = "https://${cfg.subdomain}";
        ROCKET_ADDRESS = "127.0.0.1";
        ROCKET_PORT = 8222;
      };
    };

    programs.rust-motd.settings.service_status.Vaultwarden = "vaultwarden";

    services.nginx.virtualHosts."${cfg.subdomain}" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${cfg.config.ROCKET_PORT |> toString}";
      };
    };

    services.caddy.virtualHosts = {
      "${cfg.subdomain}".extraConfig = ''
        encode zstd gzip

        reverse_proxy :${cfg.config.ROCKET_PORT |> toString} {
          header_up X-Real-IP {remote_host}
        }
      '';

      ":${toString config.server.reverse-proxy.port.vaultwarden}".extraConfig = ''
        import https
        import reverse-proxy 127.0.0.1 ${cfg.config.ROCKET_PORT |> toString}
      '';
    };
  };
}
