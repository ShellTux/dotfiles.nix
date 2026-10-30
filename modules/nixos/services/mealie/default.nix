{
  config,
  lib,
  lib',
  ...
}:
let
  inherit (builtins) elem;
  inherit (lib)
    mkOption
    mkIf
    mkDefault
    removeSuffix
    ;
  inherit (lib.types) bool;
  inherit (lib'.flake.networking) mkSiteOptions;

  cfg = config.services.mealie;
in
{
  options.services.mealie = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };

    site = mkSiteOptions {
      subdomain = "mealie";
      inherit (config.networking) fqdnOrHostName localFqdn;
      description = "Self-hosted recipe manager with meal planning, shopping lists and household organization.";
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    services.mealie = {
      listenAddress = mkDefault "127.0.0.1";
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

      homepage-dashboard.service-templates.mealie = {
        display = "Mealie";
        inherit (cfg.site)
          href
          ping
          siteMonitor
          description
          ;
        icon = "mealie.png";

        widget = {
          url = cfg.site.href;
          type = "mealie";
          key = "{{HOMEPAGE_VAR_MEALIE_KEY}}";
          version = 2;
        };
      };
    };

    programs.rust-motd.settings.service_status.Mealie =
      removeSuffix ".service" config.systemd.services.mealie.name;
  };
}
