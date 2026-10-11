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
    licenses
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
          tables
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

    nixpkgs.overlays = [
      (final: prev: {
        extraNextcloudApps = cfg.package.packages.apps // {
          noteberg = pkgs.fetchNextcloudApp {
            url = "https://github.com/thomasleuthold/NoteBerg/releases/download/0.5.42/noteberg_nextcloud-0.5.42.4.tar.gz";
            sha256 = "sha256-KrfCmpTuSY0n/Eg7whbNHReQO0JJV0i2+2TnR+EHQa8=";
            license = licenses.mit.shortName;
          };

          shoppingList = pkgs.fetchNextcloudApp {
            url = "https://github.com/otherworld-dev/Shopping-List/releases/download/v1.10.0/shopping_list.tar.gz";
            license = licenses.agpl3Plus.shortName;
            sha256 = "sha256-NHi7Me4YFO6o+SOx8K9wHlETGM1B7ybeq3bAq438bTc=";
          };

          unixUserBackend = pkgs.fetchNextcloudApp {
            url = "https://r.mateu.be/user_pwauth-2.9.1.tar.gz";
            license = licenses.agpl3Plus.shortName;
            sha256 = "sha256-PO+MeyTrNek4GiTKNMXkcGQ+25WGgurhYvNQiMrENVQ=";
          };

          countdown = pkgs.fetchNextcloudApp {
            url = "https://github.com/infinit7even/countdown/releases/download/v1.2.36/countdown.tar.gz";
            license = licenses.agpl3Plus.shortName;
            sha256 = "sha256-6WPiKZIzZameBm+vozXwPhjvo275G0M+IeKtjx0tCZI=";
          };

          analytics = pkgs.fetchNextcloudApp {
            url = "https://github.com/Rello/analytics/releases/download/6.8.1/analytics.tar.gz";
            license = licenses.agpl3Plus.shortName;
            sha256 = "sha256-i3n/2lthGHwM12quithPHkcp0ZvsfYv8i/6QSgaZu7w=";
          };

          immichIntegration = pkgs.fetchNextcloudApp {
            url = "https://github.com/xXRoxXeRXx/integration_immich/releases/download/v1.5.1/integration_immich.tar.gz";
            license = licenses.agpl3Plus.shortName;
            sha256 = "sha256-BRHNg/hFmFfB21M57yZqVd99+cJswwT4Gxug5JditG0=";
          };
        };
      })
    ];
  };
}
