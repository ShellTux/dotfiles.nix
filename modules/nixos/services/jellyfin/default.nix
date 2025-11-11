{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    mkOption
    mkIf
    mkDefault
    hasPrefix
    ;
  inherit (lib.types)
    bool
    nullOr
    str
    port
    ;

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

    subdomain = mkOption {
      description = "subdomain";
      type = str;
      default = "jellyfin.${config.server.domain}";
    };

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

    services.caddy.virtualHosts = {
      "${cfg.subdomain}".extraConfig = ''
        encode zstd gzip

        reverse_proxy :${cfg.port |> toString} {
          header_up X-Real-IP {remote_host}
        }
      '';

      ":${toString config.server.reverse-proxy.port.jellyfin}".extraConfig = ''
        import https
        import reverse-proxy 127.0.0.1 ${cfg.port |> toString}
      '';
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

    programs.rust-motd.settings.service_status.Jellyfin = "jellyfin";

    users.groups.media = { };
    users.users.jellyfin.extraGroups = [ config.users.groups.media.name ];
  };

}
