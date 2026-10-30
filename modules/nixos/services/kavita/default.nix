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

  cfg = config.services.kavita;
in
{
  options.services.kavita = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };

    site = mkSiteOptions {
      subdomain = "kavita";
      inherit (config.networking) fqdnOrHostName localFqdn;
      description = "Kavita is a fast, feature rich, cross platform reading server. Built with the goal of being a full solution for all your reading needs. Setup your own server and share your reading collection with your friends and family.";
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    services.kavita = {
      tokenKeyFile = mkDefault config.sops.secrets."services/kavita/TokenKey".path;
    };

    services = {
      caddy.virtualHosts = mkIf (cfg.site.reverse-proxy == "caddy") {
        "${cfg.site.fqdn}" = mkIf (elem "public" cfg.site.exposure) {
          extraConfig = ''
            import tls-public
            import encoding
            import coraza
            import reverse-proxy 127.0.0.1:${toString cfg.settings.Port}
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

      homepage-dashboard.service-templates.kavita = {
        display = "Kavita";
        inherit (cfg.site)
          href
          ping
          siteMonitor
          description
          ;
        icon = "kavita.png";
        widget = {
          url = cfg.site.href;
          type = "kavita";
          key = "{{HOMEPAGE_VAR_KAVITA_KEY}}";
        };
      };
    };

    programs.rust-motd.settings.service_status.Kavita =
      removeSuffix ".service" config.systemd.services.kavita.name;

    users = {
      groups.media = { };
      users."${cfg.user}".extraGroups = [ config.users.groups.media.name ];
    };

    sops.secrets."services/kavita/TokenKey" = {
      owner = cfg.user;
      mode = "0400";
    };
  };
}
