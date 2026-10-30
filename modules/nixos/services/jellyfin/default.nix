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
    hasPrefix
    removeSuffix
    ;
  inherit (lib.types)
    bool
    nullOr
    str
    port
    ;
  inherit (lib'.flake.networking) mkSiteOptions;

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
    # systemd.services.backup-jellyfin = mkIf (cfg.backupDir != null) {
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
    #     User = mkDefault user;
    #     Group = mkDefault group;
    #     ExecStart = "${pkgs.bash}/bin/bash ${./backup.sh}";
    #   };
    #   wantedBy = [ "multi-user.target" ];
    # };
    #
    # systemd.timers.backup-jellyfin = mkIf (cfg.backupDir != null) {
    #   description = "Backup jellyfin on time";
    #   timerConfig = {
    #     OnCalendar = mkDefault "23:00";
    #     Persistent = "true";
    #     Unit = "backup-jellyfin.service";
    #   };
    #   wantedBy = [ "multi-user.target" ];
    # };
    #
    # systemd.tmpfiles.settings = mkIf (cfg.backupDir != null) {
    #   "10-jellyfin".${cfg.backupDir}.d = {
    #     inherit user group;
    #     mode = "0770";
    #   };
    # };

    programs.rust-motd.settings.service_status.Jellyfin =
      removeSuffix ".service" config.systemd.services.jellyfin.name;

    users = {
      groups.media = { };
      users."${cfg.user}".extraGroups = [ config.users.groups.media.name ];
    };
  };

}
