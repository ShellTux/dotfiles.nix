{
  config,
  lib,
  lib',
  pkgs,
  ...
}:
let
  inherit (builtins)
    concatStringsSep
    elem
    filter
    isBool
    ;
  inherit (lib)
    escapeShellArg
    escapeShellArgs
    getExe'
    mapAttrsToList
    mkDefault
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    optionalString
    pipe
    types
    ;
  inherit (lib.types) bool;
  inherit (lib'.flake.networking) mkSiteOptions;

  renderFlag =
    name: value:
    if value == null then
      null
    else if isBool value then
      optionalString value "--${name}"
    else
      "--${name}=${escapeShellArg (toString value)}";

  XpraArgs = pipe cfg.xpra.args [
    (mapAttrsToList renderFlag)
    (filter (x: x != null))
    (filter (x: x != ""))
    (concatStringsSep " ")
  ];

  passwordFile = config.sops.secrets."services/jdownloader/Password".path;

  cfg = config.services.jdownloader2;

  java = getExe' pkgs.jre "java";

  launcher = pkgs.writeShellScript "jdownloader2" ''
    exec -a JDownloader ${java} ${escapeShellArgs cfg.javaOpts} -jar ${escapeShellArg "${cfg.dataDir}/JDownloader.jar"}
  '';

  caddyDownloadsPath = exposure: ''
    redir ${cfg.browser.path} ${cfg.browser.path}/ 308

    handle_path ${cfg.browser.path}* {
        ${optionalString (exposure == "public") "import authelia"}
        root * ${cfg.downloadsDir}
        file_server browse
    }
  '';
in
{
  options.services.jdownloader2 = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };

    enable = mkEnableOption "JDownloader 2";

    user = mkOption {
      type = types.str;
      default = "jdownloader";
    };

    group = mkOption {
      type = types.str;
      default = "jdownloader";
    };

    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/jdownloader";
    };

    downloadsDir = mkOption {
      type = types.str;
      default = "${cfg.dataDir}/Downloads";
    };

    openFirewall = mkEnableOption "Whether to open firewall";

    xpra = {
      port = mkOption {
        type = types.port;
        default = 14500;
      };

      displayNumber = mkOption {
        type = types.int;
        default = 100;
        example = 99;
      };

      args = mkOption {
        type = types.attrsOf (
          types.nullOr (
            types.oneOf [
              types.str
              types.int
              types.bool
            ]
          )
        );

        default = {
          bind-tcp = "127.0.0.1:${toString cfg.xpra.port},auth=file,filename=${passwordFile}";
          daemon = "no";
          dpi = 192;
          encoding = "png";
          html = "on";
          min-quality = 90;
          notifications = true;
          quality = 100;
          resize-display = "yes";
          session-name = "JDownloader";
          speaker = false;
          speed = 0;
          webcam = false;
        };
      };
    };

    javaOpts = mkOption {
      type = types.listOf types.str;
      default = [
        "-Xms512m"
        "-Xmx2048m"
      ];
    };

    site = mkSiteOptions {
      subdomain = "jdownloader";
      inherit (config.networking) fqdnOrHostName localFqdn;
      description = "JDownloader is a free, open-source download management tool with a huge community that makes downloading as easy and fast as it should be.";
    };

    browser = {
      enable = mkEnableOption "Wether to enable downloads file browser";

      path = mkOption {
        type = types.str;
        default = "/navegar";
      };
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    assertions = [
      {
        assertion = cfg.site.reverse-proxy == "caddy";
        message = "services.jdownloader2 currently only supports Caddy.";
      }
      {
        assertion = cfg.user != "root";
        message = "JDownloader must not run as root.";
      }
    ];

    services.jdownloader2 = { };

    users.groups.${cfg.group} = { };

    users.users.${cfg.user} = {
      isSystemUser = true;
      group = cfg.group;
      home = cfg.dataDir;
      createHome = true;
    };

    users.users.caddy.extraGroups = [ cfg.group ];

    services = {
      caddy.virtualHosts = mkMerge [
        (mkIf (cfg.site.reverse-proxy == "caddy") {
          "${cfg.site.fqdn}" = mkIf (elem "public" cfg.site.exposure) {
            extraConfig = ''
              import tls-public
              import encoding
              import coraza
              import reverse-proxy 127.0.0.1:${toString cfg.xpra.port}
            ''
            + optionalString cfg.browser.enable (caddyDownloadsPath "public");
          };

          "${cfg.site.localFqdn}" = mkIf (elem "local" cfg.site.exposure) {
            extraConfig = ''
              import tls-local
              import encoding
              import reverse-proxy 127.0.0.1:${toString cfg.xpra.port}
            ''
            + optionalString cfg.browser.enable (caddyDownloadsPath "local");
          };
        })
      ];

      homepage-dashboard.service-templates.jdownloader2 = {
        display = "Jdownloader2";
        inherit (cfg.site)
          href
          ping
          siteMonitor
          description
          ;
        icon = "jdownloader2.png";
        widget = {
          enable = mkDefault false;
          url = cfg.site.href;

          type = "jdownloader";
          username = "{{HOMEPAGE_VAR_JDOWNLOADER_USERNAME}}";
          password = "{{HOMEPAGE_VAR_JDOWNLOADER_PASSWORD}}";
        };
      };
    };

    systemd = {

      services.jdownloader2 = {
        description = "JDownloader 2 via Xpra";

        after = [ "network-online.target" ];
        # Not enabled at boot; start manually with `systemctl start jdownloader2`.
        wantedBy = [ ];
        wants = [ "network-online.target" ];

        path = [
          pkgs.coreutils
          pkgs.curl
          pkgs.ffmpeg
          pkgs.jre
          pkgs.mpv
          pkgs.p7zip
          pkgs.unrar-free
          pkgs.unzip
          pkgs.wget
          pkgs.xpra
          pkgs.zip
        ];

        environment = {
          HOME = cfg.dataDir;
          JD_HOME = cfg.dataDir;
          JD_DOWNLOAD_DIR = cfg.downloadsDir;
        };

        serviceConfig = {
          User = cfg.user;
          Group = cfg.group;

          WorkingDirectory = cfg.dataDir;
          StateDirectory = "jdownloader";
          RuntimeDirectory = "jdownloader";
          Environment = [ "XDG_RUNTIME_DIR=%t/jdownloader" ];

          Restart = "always";
          RestartSec = "10";

          NoNewPrivileges = true;

          PrivateTmp = true;

          ProtectSystem = "strict";
          ProtectHome = false;

          ReadWritePaths = [
            cfg.dataDir
            cfg.downloadsDir
          ];
        };

        script = ''
          if [ ! -f ${escapeShellArg "${cfg.dataDir}/JDownloader.jar"} ]; then
            install -m 0644 ${./JDownloader.jar} \
              ${escapeShellArg "${cfg.dataDir}/JDownloader.jar"}
          fi

          exec -a JDownloader xpra start :${toString cfg.xpra.displayNumber} \
              ${XpraArgs} \
              --start-child=${launcher}
        '';
      };

      tmpfiles.rules = [
        "d ${cfg.dataDir} 0755 ${cfg.user} ${cfg.group} -"
        "d ${cfg.downloadsDir} 0755 ${cfg.user} ${cfg.group} -"
      ];
    };

    sops.secrets."services/jdownloader/Password" = {
      owner = cfg.user;
      group = cfg.group;
      mode = "0400";
    };
  };
}
