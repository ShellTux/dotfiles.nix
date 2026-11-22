{
  config,
  lib,
  lib',
  ...
}:
let
  inherit (builtins) elem isString;
  inherit (lib)
    hasInfix
    hasPrefix
    mkDefault
    mkIf
    mkOption
    removeSuffix
    types
    ;
  inherit (lib.types)
    bool
    nullOr
    str
    port
    ;
  inherit (lib'.flake.networking) mkSiteOptions;

  defaultTarget = source: "/srv/jellyfin/${baseNameOf source}";

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

  cfg = config.services.jellyfin;
in
{
  options.services.jellyfin = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };

    port = mkOption {
      description = "port";
      type = port;
      default = 8096;
    };

    site = mkSiteOptions {
      subdomain = "jellyfin";
      inherit (config.networking) fqdnOrHostName localFqdn;
      description = "Free media server for organizing and streaming your personal media.";
    };

    # TODO: add module to readonly bind mount drive

    backupDir = mkOption {
      type = nullOr str;
      default = null;
      description = ''
        The directory under which jellyfin will backup its persistent data.
      '';
      example = "/var/backup/jellyfin";
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
                  Target path exposed inside the Jellyfin
                  service namespace.

                  Defaults to:
                  /srv/jellyfin/<basename(source)>
                '';
              };
            };
          })
        ]
      );

      example = [
        "/mnt/media/movies"

        "/mnt/media/tvshows:/srv/jellyfin/tvshows"

        {
          source = "/mnt/media/music";
          target = "/srv/jellyfin/music";
        }

        {
          source = "/mnt/media/anime";
        }
      ];

      description = ''
        Read-only media paths exposed to Jellyfin using
        systemd's BindReadOnlyPaths.

        Supported formats:

        - /host/path
        - /host/path:/target/path
        - { source = "..."; target = "..."; }
        - { source = "..."; }

        When no target is specified, the path is mounted at:

          /srv/jellyfin/<basename(source)>
      '';
    };

  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    assertions = [
      {
        assertion = cfg.backupDir != null -> !(hasPrefix cfg.dataDir cfg.backupDir);
        message = "Backup directory can not be in ${cfg.dataDir}";
      }
    ];

    services.jellyfin = mkDefault { };

    services = {
      caddy = {
        snippets.coraza-jellyfin = mkDefault ''
          coraza_waf {
            load_owasp_crs

            directives `
              SecAction "id:1000009,phase:1,log,pass,ctl:ruleEngine=DetectionOnly,ctl:ruleRemoveById=932260"
              SecAction "id:1000010,phase:1,log,pass,ctl:ruleEngine=DetectionOnly,ctl:ruleRemoveById=932235"
              SecAction "id:1000011,phase:1,log,pass,ctl:ruleEngine=DetectionOnly,ctl:ruleRemoveById=930130"
              SecAction "id:1000012,phase:1,log,pass,ctl:ruleEngine=DetectionOnly,ctl:ruleRemoveById=911100"

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
              import coraza-jellyfin
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
      };

      homepage-dashboard.service-templates.jellyfin = {
        display = "Jellyfin";
        inherit (cfg.site)
          href
          ping
          siteMonitor
          description
          ;
        icon = "jellyfin.png";
        widget = {
          url = cfg.site.href;

          enableBlocks = true;
          enableMediaControl = false;
          enableNowPlaying = true;
          enableUser = true;
          expandOneStreamToTwoRows = false;
          key = "{{HOMEPAGE_VAR_JELLYFIN_KEY}}";
          showEpisodeNumber = true;
          type = "jellyfin";
          version = 2;
        };
      };
    };

    # TODO: backup jellyfin
    systemd = {
      services = {
        jellyfin.serviceConfig.BindReadOnlyPaths = map normalizeMount cfg.readOnlyMediaPaths;

        # backup-jellyfin = mkIf (cfg.backupDir != null) {
        #   description = "Backup jellyfin";
        #   environment = {
        #     DATA_FOLDER = cfg.dataDir;
        #     BACKUP_FOLDER = cfg.backupDir;
        #   };
        #   path = [ pkgs.sqlite ];
        #   # if both services are started at the same time, jellyfin fails with "database is locked"
        #   before = [ "jellyfin.service" ];
        #   serviceConfig = {
        #     SyslogIdentifier = "backup-jellyfin";
        #     Type = "oneshot";
        #     User = mkDefault cfg.user;
        #     Group = mkDefault cfg.group;
        #     ExecStart = "${pkgs.bash}/bin/bash ${./backup.sh}";
        #   };
        #   wantedBy = [ "multi-user.target" ];
        # };
      };

      # timers.backup-jellyfin = mkIf (cfg.backupDir != null) {
      #   description = "Backup jellyfin on time";
      #   timerConfig = {
      #     OnCalendar = mkDefault "23:00";
      #     Persistent = "true";
      #     Unit = "backup-jellyfin.service";
      #   };
      #   wantedBy = [ "multi-user.target" ];
      # };

      # tmpfiles.settings = mkIf (cfg.backupDir != null) {
      #   "10-jellyfin".${cfg.backupDir}.d = {
      #     inherit (cfg) user group;
      #     mode = "0770";
      #   };
      # };
    };

    programs.rust-motd.settings.service_status.Jellyfin =
      removeSuffix ".service" config.systemd.services.jellyfin.name;
  };

}
