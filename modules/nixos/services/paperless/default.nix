{
  config,
  lib,
  lib',
  ...
}:
let
  inherit (builtins) elem;
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool;
  inherit (lib'.flake.networking) mkSiteOptions;

  cfg = config.services.paperless;
in
{
  options.services.paperless = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };

    site = mkSiteOptions {
      subdomain = "paperless";
      inherit (config.networking) fqdnOrHostName localFqdn;
      description = "A community-supported supercharged document management system: scan, index and archive all your documents";
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    services.paperless = {
      domain = mkDefault cfg.site.domain;
      passwordFile = config.sops.secrets."services/paperless/AdminPassword".path;
      exporter = {
        enable = mkDefault true;
        settings = {
          compare-checksums = true;
          delete = true;
          no-color = true;
          no-progress-bar = true;
        };
      };
      settings = {
        PAPERLESS_CONSUMER_IGNORE_PATTERN = [
          ".DS_STORE/*"
          "desktop.ini"
        ];
        # PAPERLESS_OCR_LANGUAGE = "por+deu+eng";
        PAPERLESS_OCR_USER_ARGS = {
          optimize = 1;
          pdfa_image_compression = "lossless";
        };
      };
    };

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

      homepage-dashboard.service-templates.paperless = {
        display = "Paperless";
        inherit (cfg.site)
          href
          ping
          siteMonitor
          description
          ;
        icon = "paperless.png";
        widget = {
          url = cfg.site.href;

          key = "{{HOMEPAGE_VAR_PAPERLESS_KEY}}";
          type = "paperlessngx";
        };
      };
    };

    sops.secrets."services/paperless/AdminPassword" = {
      owner = cfg.user;
      group = cfg.group;
      reloadUnits = [ config.systemd.services.paperless-web.name ];
    };
  };
}
