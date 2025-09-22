{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool;

  domain = "example.com";
  subdomain = "vaultwarden.${domain}";

  cfg = config.services.vaultwarden;
in
{
  options.services.vaultwarden = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    services.vaultwarden = mkDefault {
      backupDir = "/var/backup/vaultwarden";
      config = {
        DOMAIN = "https://${subdomain}";
        ROCKET_ADDRESS = "127.0.0.1";
        ROCKET_PORT = 8222;
      };
    };

    services.nginx.virtualHosts."${subdomain}" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${cfg.config.ROCKET_PORT |> toString}";
      };
    };

    services.caddy.virtualHosts = {
      "${subdomain}".extraConfig = ''
        encode zstd gzip

        reverse_proxy :${cfg.config.ROCKET_PORT |> toString} {
          header_up X-Real-IP {remote_host}
        }
      '';

      ":7002".extraConfig = ''
        import https
        import reverse-proxy 127.0.0.1 ${cfg.config.ROCKET_PORT |> toString}
      '';
    };
  };
}
