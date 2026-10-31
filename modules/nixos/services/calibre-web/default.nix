{
  config,
  lib,
  lib',
  ...
}:
let
  inherit (builtins) elem;
  inherit (lib) mkDefault mkOption mkIf;
  inherit (lib.types) bool;
  inherit (lib'.flake.networking) mkSiteOptions;

  cfg = config.services.calibre-web;
in
{
  options.services.calibre-web = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };

    site = mkSiteOptions {
      subdomain = "calibre";
      inherit (config.networking) fqdnOrHostName localFqdn;
      description = "Calibre-Web is a web app that offers a clean and intuitive interface for browsing, reading, and downloading eBooks using a valid Calibre database.";
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    services.calibre-web = {
      listen.ip = mkDefault "127.0.0.1";
    };

    services = {
      caddy.virtualHosts = mkIf (cfg.site.reverse-proxy == "caddy") {
        "${cfg.site.fqdn}" = mkIf (elem "public" cfg.site.exposure) {
          extraConfig = ''
            import tls-public
            import encoding
            import coraza
            import reverse-proxy ${cfg.listen.ip}:${toString cfg.listen.port}
          '';
        };

        "${cfg.site.localFqdn}" = mkIf (elem "local" cfg.site.exposure) {
          extraConfig = ''
            import tls-local
            import encoding
            import reverse-proxy ${cfg.listen.ip}:${toString cfg.listen.port}
          '';
        };
      };

      homepage-dashboard.service-templates.calibre = {
        display = "Calibre";
        inherit (cfg.site)
          href
          ping
          siteMonitor
          description
          ;
        icon = "calibre.png";
        widget = mkIf false {
          url = cfg.site.href;

          type = "calibreweb";
          username = "";
          password = "";
        };
      };
    };

    users = {
      groups.media = { };
      users."${cfg.user}".extraGroups = [ config.users.groups.media.name ];
    };
  };
}
