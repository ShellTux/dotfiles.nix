{
  config,
  lib,
  lib',
  ...
}:
let
  inherit (builtins) elem;
  inherit (lib)
    mkDefault
    mkOption
    mkIf
    removeSuffix
    ;
  inherit (lib.types) bool;
  inherit (lib'.flake.networking) mkSiteOptions;

  cfg = config.services.vaultwarden;
in
{
  options.services.vaultwarden = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };

    site = mkSiteOptions {
      subdomain = "vaultwarden";
      inherit (config.networking) fqdnOrHostName localFqdn;
      description = "Self-hosted password manager for securely storing passwords and notes.";
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    services.vaultwarden = {
      backupDir = "/var/backup/vaultwarden";
      config = {
        # DOMAIN = "https://${cfg.proxy.computedDomain}";
        ROCKET_ADDRESS = "127.0.0.1";
        ROCKET_PORT = 8222;
      };
    };

    programs.rust-motd.settings.service_status.Vaultwarden =
      removeSuffix ".service" config.systemd.services.vaultwarden.name;

    services = {
      caddy = {
        snippets.coraza-vaultwarden = mkDefault ''
          coraza_waf {
            load_owasp_crs

            directives `
              SecRule REQUEST_URI "@beginsWith /api/" "id:1000001,phase:1,pass,log,ctl:ruleRemoveById=911100"
              SecRule REQUEST_URI "@beginsWith /api/" "id:1000002,phase:1,pass,log,ctl:ruleRemoveById=911101"

              Include @coraza.conf-recommended
              Include @crs-setup.conf.example
              Include @owasp_crs/*.conf

              SecRuleEngine On
            `
          }
        '';

        virtualHosts = mkIf (cfg.site.reverse-proxy == "caddy") {
          "${cfg.site.fqdn}" = mkIf (elem "public" cfg.site.exposure) {
            extraConfig = ''
              import tls-public
              import encoding
              import coraza-vaultwarden
              import reverse-proxy 127.0.0.1:${toString cfg.config.ROCKET_PORT}
            '';
          };

          "${cfg.site.localFqdn}" = mkIf (elem "local" cfg.site.exposure) {
            extraConfig = ''
              import tls-local
              import encoding
              import reverse-proxy 127.0.0.1:${toString cfg.config.ROCKET_PORT}
            '';
          };
        };
      };

      homepage-dashboard.service-templates.vaultwarden = {
        display = "Vaultwarden";
        inherit (cfg.site)
          description
          href
          ping
          siteMonitor
          ;
        icon = "vaultwarden.png";
      };
    };
  };
}
