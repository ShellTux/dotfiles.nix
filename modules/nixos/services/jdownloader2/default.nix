{
  config,
  lib,
  lib',
  pkgs,
  ...
}:
let
  inherit (builtins) elem;
  inherit (lib)
    getExe
    getExe'
    mkEnableOption
    mkIf
    mkOption
    optional
    optionalAttrs
    optionals
    types
    ;
  inherit (lib.types) bool;
  inherit (lib'.flake.networking) mkSiteOptions;

  novnc = getExe pkgs.small.novnc;
  openbox = getExe' pkgs.openbox "openbox";
  x11vnc = getExe pkgs.x11vnc;
  Xvfb = getExe' pkgs.xorg-server "Xvfb";

  display = ":${toString cfg.gui.display}";

  cfg = config.services.jdownloader2;
in
{
  options.services.jdownloader2 = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };

    enable = mkEnableOption "JDownloader 2";

    package = mkOption {
      type = types.package;
      default = pkgs.callPackage ./jdownloader { };
      description = "JDownloader package.";
    };

    user = mkOption {
      type = types.str;
      default = "jdownloader";
    };

    group = mkOption {
      type = types.str;
      default = "jdownloader";
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/jdownloader";
    };

    downloadsDir = mkOption {
      type = types.path;
      default = "/var/lib/jdownloader/downloads";
    };

    openFirewall = mkEnableOption "Whether to open firewall";

    javaOpts = mkOption {
      type = types.listOf types.str;
      default = [
        "-Xms512m"
        "-Xmx2048m"
      ];
    };

    gui = {

      enable = mkOption {
        type = types.bool;
        default = true;
      };

      display = mkOption {
        type = types.int;
        default = 99;
      };

      resolution = {

        width = mkOption {
          type = types.int;
          default = 1280;
        };

        height = mkOption {
          type = types.int;
          default = 720;
        };

        depth = mkOption {
          type = types.int;
          default = 24;
        };
      };

      vnc = {

        enable = mkOption {
          type = types.bool;
          default = true;
        };

        port = mkOption {
          type = types.port;
          default = 5900;
        };
      };

      web = {

        enable = mkOption {
          type = types.bool;
          default = true;
        };

        port = mkOption {
          type = types.port;
          default = 5800;
        };
      };
    };

    site = mkSiteOptions {
      subdomain = "jdownloader";
      inherit (config.networking) fqdnOrHostName localFqdn;
      description = "JDownloader is a free, open-source download management tool with a huge community that makes downloading as easy and fast as it should be.";
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    services.jdownloader2 = { };

    users.groups.${cfg.group} = { };

    users.users.${cfg.user} = {
      isSystemUser = true;
      group = cfg.group;
      home = cfg.dataDir;
      createHome = true;
    };

    services = {
      caddy.virtualHosts = mkIf (cfg.site.reverse-proxy == "caddy") {
        "${cfg.site.fqdn}" = mkIf (elem "public" cfg.site.exposure) {
          extraConfig = ''
            import tls-public
            import encoding
            import coraza
            import reverse-proxy 127.0.0.1:${toString cfg.gui.web.port}
          '';
        };

        "${cfg.site.localFqdn}" = mkIf (elem "local" cfg.site.exposure) {
          extraConfig = ''
            import tls-local
            import encoding
            import reverse-proxy 127.0.0.1:${toString cfg.gui.web.port}
          '';
        };
      };

      homepage-dashboard.service-templates.jdownloader2 = {
        display = "Jdownloader2";
        inherit (cfg.site)
          href
          ping
          siteMonitor
          description
          ;
        icon = "jdownloader2.png";
        widget = mkIf false {
          url = cfg.site.href;

          type = "jdownloader";
          username = "{{HOMEPAGE_VAR_JDOWNLOADER_USERNAME}}";
          password = "{{HOMEPAGE_VAR_JDOWNLOADER_PASSWORD}}";
        };
      };
    };

    networking.firewall.allowedTCPPorts =
      optionals (cfg.openFirewall && cfg.gui.web.enable) [ cfg.gui.web.port ]
      ++ optionals (cfg.openFirewall && cfg.gui.vnc.enable) [ cfg.gui.vnc.port ];

    systemd = {
      services.jdownloader-xvfb = mkIf cfg.gui.enable {
        description = "JDownloader Xvfb";

        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          User = cfg.user;
          Group = cfg.group;
          Restart = "always";
        };

        script = ''
          exec ${Xvfb} \
            ${display} \
            -screen 0 \
            ${toString cfg.gui.resolution.width}x${toString cfg.gui.resolution.height}x${toString cfg.gui.resolution.depth}
        '';
      };

      services.jdownloader-openbox = mkIf cfg.gui.enable {
        description = "JDownloader Openbox";

        after = [
          "jdownloader-xvfb.service"
        ];

        requires = [
          "jdownloader-xvfb.service"
        ];

        wantedBy = [ "multi-user.target" ];

        environment = {
          DISPLAY = display;
        };

        serviceConfig = {
          User = cfg.user;
          Group = cfg.group;
          Restart = "always";
        };

        script = ''
          exec ${openbox}
        '';
      };

      services.jdownloader2 = {
        description = "JDownloader 2";

        after = [
          "network-online.target"
        ]
        ++ optional cfg.gui.enable "jdownloader-xvfb.service"
        ++ optional cfg.gui.enable "jdownloader-openbox.service";

        wants = [
          "network-online.target"
        ]
        ++ optional cfg.gui.enable "jdownloader-xvfb.service"
        ++ optional cfg.gui.enable "jdownloader-openbox.service";

        wantedBy = [ "multi-user.target" ];

        path = [
          pkgs.coreutils
          pkgs.curl
          pkgs.ffmpeg
          pkgs.p7zip
          pkgs.unrar-free
          pkgs.unzip
          pkgs.wget
          pkgs.zip
        ];

        environment = {
          HOME = cfg.dataDir;
          JD_HOME = cfg.dataDir;
          JD_DOWNLOAD_DIR = cfg.downloadsDir;
        }
        // optionalAttrs cfg.gui.enable {
          DISPLAY = display;
        };

        serviceConfig = {
          User = cfg.user;
          Group = cfg.group;

          WorkingDirectory = cfg.dataDir;
          StateDirectory = "jdownloader";

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
          if [ ! -f ${cfg.dataDir}/.installed ]
          then
            cp --archive ${cfg.package}/share/jdownloader/. ${cfg.dataDir}/
            touch ${cfg.dataDir}/.installed
          fi

          chmod +x ${cfg.dataDir}/JDownloader2

          exec ${cfg.dataDir}/JDownloader2
        '';
      };

      services.jdownloader-vnc = mkIf (cfg.gui.enable && cfg.gui.vnc.enable) {

        description = "JDownloader x11vnc";

        after = [
          "jdownloader-xvfb.service"
        ];

        requires = [
          "jdownloader-xvfb.service"
        ];

        wantedBy = [ "multi-user.target" ];

        environment = {
          DISPLAY = display;
        };

        serviceConfig = {
          User = cfg.user;
          Group = cfg.group;
          Restart = "always";
        };

        script = ''
          exec ${x11vnc} \
            -display ${display} \
            -forever \
            -shared \
            -nopw \
            -rfbport ${toString cfg.gui.vnc.port}
        '';
      };

      services.jdownloader-novnc = mkIf (cfg.gui.enable && cfg.gui.web.enable) {

        description = "JDownloader noVNC";

        after = [
          "jdownloader-vnc.service"
        ];

        requires = [
          "jdownloader-vnc.service"
        ];

        wantedBy = [ "multi-user.target" ];

        path = [
          pkgs.coreutils
          pkgs.procps
          pkgs.small.python314Packages.websockify
        ];

        serviceConfig = {
          User = cfg.user;
          Group = cfg.group;
          Restart = "always";
        };

        script = ''
          exec ${novnc} \
            --listen ${toString cfg.gui.web.port} \
            --vnc localhost:${toString cfg.gui.vnc.port}
        '';
      };

      tmpfiles.rules = [
        "d ${cfg.dataDir} 0755 ${cfg.user} ${cfg.group} -"
        "d ${cfg.downloadsDir} 0755 ${cfg.user} ${cfg.group} -"
      ];
    };
  };
}
