{
  config,
  lib,
  lib',
  pkgs,
  ...
}:
let
  inherit (builtins) concatStringsSep elem;
  inherit (lib)
    escapeShellArg
    getExe
    getExe'
    licenses
    mapAttrsToList
    mkDefault
    mkForce
    mkIf
    mkOption
    optionalAttrs
    optionalString
    removeSuffix
    types
    ;
  inherit (lib'.flake.networking) mkSiteOptions;

  fpm = config.services.phpfpm.pools.nextcloud;
  webserver = config.services."${cfg.webserver}";

  cfg = config.services.nextcloud;
in
{
  options.services.nextcloud = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = types.bool;
      default = false;
    };

    ensureUsers = mkOption {
      default = { };
      description = lib.mdDoc ''
        List of user accounts which get automatically created if they don't
        exist yet. This option does not delete accounts which are not listed
        anymore.
      '';
      example = {
        user1 = {
          passwordFile = /secrets/user1-localhost;
          email = "user1@localhost";
        };
        user2 = {
          passwordFile = /secrets/user2-localhost;
          email = "user2@localhost";
        };
      };

      type = types.attrsOf (
        types.submodule {
          options = {
            passwordFile = mkOption {
              type = types.path;
              example = "/path/to/file";
              default = null;
              description = lib.mdDoc ''
                Specifies the path to a file containing the
                clear text password for the user.
              '';
            };
            email = mkOption {
              type = types.str;
              example = "user1@localhost";
              default = null;
            };
          };
        }
      );
    };

    webserver = mkOption {
      type = types.enum [
        "nginx"
        "caddy"
      ];
      default = "nginx";
      description = ''
        Whether to use nginx or caddy for virtual host management.
        Further nginx configuration can be done by adapting <literal>services.nginx.virtualHosts.&lt;name&gt;</literal>.
        See <xref linkend="opt-services.nginx.virtualHosts"/> for further information.
      '';
    };

    extraOCCCommands = mkOption {
      default = "";
      type = types.lines;
      example = "nextcloud-occ app:enable cleanup";
      description = lib.mdDoc ''
        Extra OCC commands which get executed after setup.
      '';
    };

    site = mkSiteOptions {
      subdomain = "nextcloud";
      inherit (config.networking) fqdnOrHostName localFqdn;
      description = "Nextcloud é uma plataforma de colaboração em nuvem de código aberto que possibilita a criação de servidores de hospedagem de arquivos privados ou empresariais.";
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    services.nextcloud = {
      package = pkgs.nextcloud35;
      hostName = mkDefault cfg.site.fqdn;
      enableImagemagick = true;
      https = mkDefault true;

      config = {
        dbtype = "sqlite";
      };

      settings = {
        forwarded_for_headers = [ "HTTP_X_FORWARDED_FOR" ];
        maintenance_window_start = 3;
        memories.exiftool = getExe pkgs.exiftool;
        memories.vod.ffmpeg = getExe pkgs.ffmpeg-headless;
        memories.vod.ffprobe = getExe' pkgs.ffmpeg-headless "ffprobe";
        preview_ffmpeg_path = getExe' pkgs.ffmpeg-headless "ffmpeg";
        trusted_proxies = [ "127.0.0.1" ];
      };

      extraAppsEnable = mkDefault true;
      extraApps = mkDefault {
        inherit (config.services.nextcloud.package.packages.apps)
          calendar
          checksum
          collectives
          contacts
          cookbook
          deck
          drawio
          end_to_end_encryption
          forms
          mail
          maps
          music
          news
          notes
          oidc
          oidc_login
          onlyoffice
          pantry
          phonetrack
          polls
          previewgenerator
          quota_warning
          richdocuments
          tables
          tasks
          theming_customcss
          whiteboard
          ;

        inherit (pkgs.extraNextcloudApps) shoppingList;
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

      nginx = mkIf (cfg.webserver == "caddy") {
        enable = mkForce false;
        recommendedGzipSettings = true;
        recommendedOptimisation = true;
        recommendedTlsSettings = true;
        recommendedProxySettings = true;
        defaultHTTPListenPort = mkForce cfg.port;
        defaultSSLListenPort = mkForce 8443;
        defaultListenAddresses = mkForce [ "127.0.0.1" ];
      };

      caddy = mkIf (cfg.webserver == "caddy") {
        enable = mkDefault true;

        snippets.coraza-nextcloud = mkDefault ''
          coraza_waf {
            load_owasp_crs

            directives `
              SecAction "id:1000003,phase:1,log,pass,ctl:ruleEngine=DetectionOnly,ctl:ruleRemoveById=911100"
              SecAction "id:1000004,phase:1,log,pass,ctl:ruleEngine=DetectionOnly,ctl:ruleRemoveById=911101"
              SecAction "id:1000005,phase:1,log,pass,ctl:ruleEngine=DetectionOnly,ctl:ruleRemoveById=941100"
              SecAction "id:1000006,phase:1,log,pass,ctl:ruleEngine=DetectionOnly,ctl:ruleRemoveById=941130"
              SecAction "id:1000007,phase:1,log,pass,ctl:ruleEngine=DetectionOnly,ctl:ruleRemoveById=920420"
              SecAction "id:1000008,phase:1,log,pass,ctl:ruleEngine=DetectionOnly,ctl:ruleRemoveById=932235"

              Include @coraza.conf-recommended
              Include @crs-setup.conf.example
              Include @owasp_crs/*.conf

              SecRuleEngine On
            `
          }
        '';

        virtualHosts =
          let
            nextCloudCaddyConfig = ''
              root * ${config.services.nginx.virtualHosts.${cfg.hostName}.root}

              redir /.well-known/carddav /remote.php/dav 301
              redir /.well-known/caldav /remote.php/dav 301
              redir /.well-known/* /index.php{uri} 301
              redir /remote/* /remote.php{uri} 301

              header {
                Strict-Transport-Security max-age=31536000
                Permissions-Policy interest-cohort=()
                X-Content-Type-Options nosniff
                X-Frame-Options SAMEORIGIN
                Referrer-Policy no-referrer
                X-XSS-Protection "1; mode=block"
                X-Permitted-Cross-Domain-Policies none
                X-Robots-Tag "noindex, nofollow"
                -X-Powered-By
              }

              php_fastcgi unix/${fpm.socket} {
                root ${config.services.nginx.virtualHosts.${cfg.hostName}.root}
                env front_controller_active true
                env modHeadersAvailable true
              }

              @forbidden {
                path /build/* /tests/* /config/* /lib/* /3rdparty/* /templates/* /data/*
                path /.* /autotest* /occ* /issue* /indie* /db_* /console*
                not path /.well-known/*
              }
              error @forbidden 404

              @immutable {
                path *.css *.js *.mjs *.svg *.gif *.png *.jpg *.ico *.wasm *.tflite
                query v=*
              }
              header @immutable Cache-Control "max-age=15778463, immutable"

              @static {
                path *.css *.js *.mjs *.svg *.gif *.png *.jpg *.ico *.wasm *.tflite
                not query v=*
              }
              header @static Cache-Control "max-age=15778463"

              @woff2 path *.woff2
              header @woff2 Cache-Control "max-age=604800"

              file_server
            '';
          in
          {
            "${cfg.site.fqdn}" = mkIf (elem "public" cfg.site.exposure) {
              extraConfig = ''
                import tls-public
                import encoding
                import coraza-nextcloud

                ${nextCloudCaddyConfig}
              '';
            };

            "${cfg.site.localFqdn}" = mkIf (elem "local" cfg.site.exposure) {
              extraConfig = ''
                import tls-local
                import encoding

                ${nextCloudCaddyConfig}
              '';
            };
          };

      };

      homepage-dashboard.service-templates.nextcloud = {
        display = "Nextcloud";
        inherit (cfg.site)
          href
          ping
          siteMonitor
          description
          ;
        icon = "nextcloud.png";

        widget = mkIf false {
          url = cfg.site.href;
          type = "nextcloud";
          key = "{{HOMEPAGE_VAR_NEXTCLOUD_KEY}}";
          fields = [
            "cpuload"
            "memoryusage"
            "freespace"
            "activeusers"
            "numfiles"
            "numshares"
          ];
        };
      };

      phpfpm.pools.nextcloud.settings = {
        "listen.owner" = webserver.user;
        "listen.group" = webserver.group;
      };
    };

    programs.rust-motd.settings.service_status.Nextcloud =
      removeSuffix ".service" config.systemd.services.phpfpm-nextcloud.name;

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

    systemd.services.nextcloud-ensure-users = {
      enable = mkForce false;
      script = ''
        ${optionalString (cfg.ensureUsers != { }) ''
          ${concatStringsSep "\n" (
            mapAttrsToList (name: cfg: ''
              if ${config.services.nextcloud.occ}/bin/nextcloud-occ user:info "${name}" | grep "user not found"; then
                export OC_PASS="$(cat ${escapeShellArg cfg.passwordFile})"
                ${config.services.nextcloud.occ}/bin/nextcloud-occ user:add --password-from-env "${name}"
              fi
              ${optionalString (cfg.email != null) ''
                ${config.services.nextcloud.occ}/bin/nextcloud-occ user:setting "${name}" settings email "${cfg.email}"
              ''}
            '') cfg.ensureUsers
          )}
        ''}
      '';
      wantedBy = [ "multi-user.target" ];
      after = [ "nextcloud-setup.service" ];
    };

    systemd.services.nextcloud-extra-occ-commands = {
      enable = true;
      script = ''
        ${cfg.extraOCCCommands}
      '';
      wantedBy = [ "multi-user.target" ];
      after = [ "nextcloud-setup.service" ];
    };

    users.groups.nextcloud.members = [
      "nextcloud"
      webserver.user
    ];
  };
}
