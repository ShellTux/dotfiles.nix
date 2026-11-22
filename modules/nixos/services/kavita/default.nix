{
  config,
  lib,
  lib',
  ...
}:
let
  inherit (builtins) elem isString length;
  inherit (lib)
    hasInfix
    mkDefault
    mkIf
    mkOption
    removeSuffix
    types
    ;
  inherit (lib.types) bool;
  inherit (lib'.flake.networking) mkSiteOptions;

  defaultTarget = source: "/srv/kavita/${baseNameOf source}";

  normalizeMount =
    entry:
    if isString entry then
      if hasInfix ":" entry then entry else "${entry}:${defaultTarget entry}"
    else
      let
        inherit (entry) source;
        target = if entry.target != null then entry.target else defaultTarget source;
      in
      "${source}:${target}";

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

    readOnlyMediaPaths = mkOption {
      default = [ ];

      type = types.listOf (
        types.oneOf [
          types.str
          (types.submodule {
            options = {
              source = mkOption {
                type = types.str;
                description = "Source path on the host.";
              };

              target = mkOption {
                type = types.nullOr types.str;
                default = null;
                description = ''
                  Target path exposed inside the kavita
                  service namespace.

                  Defaults to:
                  /srv/kavita/<basename(source)>
                '';
              };
            };
          })
        ]
      );

      example = [
        "/mnt/media/movies"

        "/mnt/media/tvshows:/srv/kavita/tvshows"

        {
          source = "/mnt/media/music";
          target = "/srv/kavita/music";
        }

        {
          source = "/mnt/media/anime";
        }
      ];

      description = ''
        Read-only media paths exposed to Kavita using
        systemd's BindReadOnlyPaths.

        Supported formats:

        - /host/path
        - /host/path:/target/path
        - { source = "..."; target = "..."; }
        - { source = "..."; }

        When no target is specified, the path is mounted at:

          /srv/kavita/<basename(source)>
      '';
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

    systemd.services.kavita.serviceConfig = mkIf (length cfg.readOnlyMediaPaths > 0) {
      BindReadOnlyPaths = map normalizeMount cfg.readOnlyMediaPaths;
    };

    sops.secrets."services/kavita/TokenKey" = {
      owner = cfg.user;
      mode = "0400";
    };
  };
}
