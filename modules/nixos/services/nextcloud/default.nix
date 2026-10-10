{
  config,
  lib,
  lib',
  pkgs,
  ...
}:
let
  inherit (lib)
    getExe
    getExe'
    mkDefault
    mkForce
    mkIf
    mkOption
    optional
    optionalAttrs
    ;
  inherit (lib.types) bool port;
  inherit (lib'.flake.caddy) mkProxyOption;

  inherit (config.services) caddy;

  cfg = config.services.nextcloud;
in
{
  options.services.nextcloud = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };

    port = mkOption {
      description = "port";
      type = port;
      default = 8080;
    };

    proxy = mkProxyOption {
      inherit (config.networking) naming;
      name = "nextcloud";
      upstream.port = cfg.port;
      coraza.initialConfig = ''
        SecAction "id:1000003,\
            phase:1,\
            log,\
            pass,\
            ctl:ruleEngine=DetectionOnly,\
            ctl:ruleRemoveById=911100"

        SecAction "id:1000004,\
            phase:1,\
            log,\
            pass,\
            ctl:ruleEngine=DetectionOnly,\
            ctl:ruleRemoveById=911101"

        SecAction "id:1000005,\
            phase:1,\
            log,\
            pass,\
            ctl:ruleEngine=DetectionOnly,\
            ctl:ruleRemoveById=941100"

        SecAction "id:1000006,\
            phase:1,\
            log,\
            pass,\
            ctl:ruleEngine=DetectionOnly,\
            ctl:ruleRemoveById=941130"

        SecAction "id:1000007,\
            phase:1,\
            log,\
            pass,\
            ctl:ruleEngine=DetectionOnly,\
            ctl:ruleRemoveById=920420"

        SecAction "id:1000008,\
            phase:1,\
            log,\
            pass,\
            ctl:ruleEngine=DetectionOnly,\
            ctl:ruleRemoveById=932235"
      '';
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    services.nextcloud = {
      package = pkgs.nextcloud34;
      hostName = mkDefault cfg.proxy.computedFqdn;
      enableImagemagick = true;
      https = mkDefault true;

      config = {
        adminuser = "admin";
        adminpassFile = mkDefault "/etc/nextcloud-admin-pass";
        dbtype = "sqlite";
      };

      settings = {
        memories.exiftool = getExe pkgs.exiftool;
        memories.vod.ffmpeg = getExe pkgs.ffmpeg-headless;
        memories.vod.ffprobe = getExe' pkgs.ffmpeg-headless "ffprobe";
        preview_ffmpeg_path = getExe' pkgs.ffmpeg-headless "ffmpeg";
      };

      extraAppsEnable = mkDefault true;
      extraApps = mkDefault {
        inherit (config.services.nextcloud.package.packages.apps)
          calendar
          polls
          collectives
          contacts
          cookbook
          deck
          drawio
          end_to_end_encryption
          forms
          mail
          maps
          memories
          news
          notes
          onlyoffice
          richdocuments
          tasks
          whiteboard
          ;
      };
    };

    services = {
      fail2ban.jails.nextcloud.settings = {
        # START modification to work with syslog instead of logile
        backend = "systemd";
        journalmatch = "SYSLOG_IDENTIFIER=Nextcloud";
        # END modification to work with syslog instead of logile
        enabled = true;
        port = 443;
        protocol = "tcp";
        filter = "nextcloud";
        maxretry = 3;
        bantime = 86400;
        findtime = 43200;
      };

      nginx = optionalAttrs caddy.enable {
        enable = mkForce true;
        recommendedGzipSettings = true;
        recommendedOptimisation = true;
        recommendedTlsSettings = true;
        recommendedProxySettings = true;
        defaultHTTPListenPort = mkForce cfg.port;
        defaultSSLListenPort = mkForce 8443;
        defaultListenAddresses = mkForce [ "127.0.0.1" ];
      };

      caddy.proxies = optional cfg.proxy.enable cfg.proxy;
    };

    programs.rust-motd.settings.service_status.Nextcloud = "nginx";

    environment.etc."nextcloud-admin-pass".text = mkDefault "changeme";
  };
}
