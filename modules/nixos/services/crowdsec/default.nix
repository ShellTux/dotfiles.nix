{
  config,
  lib,
  ...
}:
let
  inherit (builtins) attrNames length;
  inherit (lib)
    mkOption
    mkIf
    mkDefault
    pipe
    optional
    optionals
    ;
  inherit (lib.types) bool;
  inherit (config.services)
    authelia
    caddy
    grafana
    immich
    jellyfin
    mealie
    openssh
    sshd
    vaultwarden
    ;

  rootDir = "/var/lib/crowdsec";
  stateDir = "${rootDir}/state";

  cfg = config.services.crowdsec;
in
{
  options.services.crowdsec = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    services.crowdsec = {
      settings = {
        general.api.server.enable = true;
        lapi.credentialsFile = "${stateDir}/lapi.yaml";
        capi.credentialsFile = "${stateDir}/capi.yaml";
        console.tokenFile = config.sops.secrets."crowdsec/enrollKey".path;
      };

      hub.collections = [
        "crowdsecurity/linux"
      ]
      ++ optional authelia.enabled "LePresidente/authelia"
      ++ optional caddy.enable "crowdsecurity/caddy"
      ++ optional grafana.enable "LePresidente/grafana"
      ++ optional immich.enable "gauth-fr/immich"
      ++ optional jellyfin.enable "LePresidente/jellyfin"
      ++ optional mealie.enable "Jgigantino31/mealie"
      ++ optional (openssh.enable || sshd.enable) "crowdsecurity/sshd"
      ++ optional vaultwarden.enable "Dominic-Wagner/vaultwarden";

      localConfig.acquisitions =
        optionals authelia.enabled [
          {
            filenames = [ ];
            labels.type = "authelia";
          }
        ]
        ++ optionals caddy.enable [
          {
            filenames = [ "${caddy.logDir}/*.log" ];
            labels.type = "caddy";
          }
        ]
        ++ optionals jellyfin.enable [
          {
            filenames = [ "${jellyfin.logDir}/log_*.log" ];
            labels.type = "jellyfin";
          }
        ]
        ++ optionals vaultwarden.enable [
          {
            source = "journalctl";
            journalctl_filter = [ "SYSLOG_IDENTIFIER=vaultwarden" ];
            labels.type = "syslog";
          }
        ]
        ++ optionals grafana.enable [
          {
            filenames = [ ];
            labels.type = "grafana";
          }
        ]
        ++ optionals immich.enable [
          {
            filenames = [ ];
            labels.type = "immich";
          }
        ]
        ++ optionals mealie.enable [
          {
            filenames = [ ];
            labels.type = "mealie";
          }
        ];
    };

    users.users.crowdsec.extraGroups = [ "systemd-journal" ] ++ optional caddy.enable caddy.group;

    sops.secrets."services/crowdsec/enrollKey" = {
      group = "crowdsec";
      owner = "crowdsec";
    };
  };
}
