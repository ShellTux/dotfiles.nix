{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (builtins)
    attrNames
    concatStringsSep
    map
    ;
  inherit (lib)
    getExe
    getExe'
    mkDefault
    mkEnableOption
    mkIf
    mkOption
    pipe
    ;
  inherit (lib.types)
    attrsOf
    bool
    listOf
    nullOr
    package
    str
    submodule
    ;
  inherit (pkgs) writeText writeShellScriptBin;

  mkScript =
    name: script:
    pipe script [
      (writeShellScriptBin name)
      getExe
    ];

  serviceConfig = {
    Type = "simple";
    Nice = 19;
    IOSchedulingClass = "idle";
  };

  directoryModule = submodule {
    options = {
      path = mkOption {
        type = str;
        example = "/Media";
        description = "Directory to monitor.";
      };

      rule = mkOption {
        type = str;
        example = "MediaRule";
        description = "Rule name to apply.";
      };

      exclude = mkOption {
        type = listOf str;
        default = [ ];
        example = [
          ".Trash"
          ".cache"
          "Plex"
        ];
        description = "Patterns to exclude inside this directory.";
      };
    };
  };

  rulesText = pipe cfg.rules [
    attrNames
    (map (name: "${name} = ${cfg.rules.${name}}"))
    (concatStringsSep "\n")
  ];

  dirsText = pipe cfg.directories [
    (map (dir: {
      inherit (dir) path rule;
      exclude = pipe dir.exclude [
        (map (e: "!${dir.path}/**/${e}"))
        (concatStringsSep "\n")
      ];
    }))
    (map (dir: "${dir.path} ${dir.rule}\n${dir.exclude}"))
    (concatStringsSep "\n")
  ];

  aideConf = writeText "aide.conf" ''
    # Database
    database_in=file:${cfg.libDir}/aide.db
    database_out=file:${cfg.libDir}/aide.db.new

    # Report Urls
    report_url=stdout
    report_url=file:${cfg.logDir}/aide.log

    # Begin rules
    ${rulesText}

    # Begin Directories
    ${dirsText}
  '';

  aide = getExe cfg.package;
  echo = getExe' pkgs.coreutils "echo";
  mail = getExe' pkgs.mailutils "mail";
  mkdir = getExe' pkgs.coreutils "mkdir";
  mv = getExe' pkgs.coreutils "mv";

  cfg = config.services.aide;
in
{
  options.services.aide = {
    enable = mkEnableOption "AIDE integrity checker";

    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };

    package = mkOption {
      type = package;
      default = pkgs.aide;
      description = "The aide package to use.";
    };

    libDir = mkOption {
      type = str;
      default = "/var/lib/aide";
      description = "Path to AIDE lib dir";
    };

    logDir = mkOption {
      type = str;
      default = "/var/log/aide";
      description = "Path to AIDE log dir";
    };

    rules = mkOption {
      type = attrsOf str;
      default = { };
      example = {
        MediaRule = "sha256+size+mtime";
        StrictRule = "sha512+size+mtime+inode+permissions";
      };
      description = "Custom AIDE rule definitions.";
    };

    directories = mkOption {
      type = listOf directoryModule;
      default = [ ];
      description = "List of directories monitored by AIDE.";
    };

    checkInterval = mkOption {
      type = str;
      default = "daily";
      description = "Systemd timer interval for AIDE checks.";
    };

    alertEmail = mkOption {
      type = nullOr str;
      default = null;
      example = "admin@example.com";
      description = "Email address to send AIDE alerts (requires mail system configured)";
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    services.aide = mkDefault { };

    environment = {
      etc."aide.conf".source = aideConf;
      systemPackages = [
        pkgs.crc32c
      ];
    };

    systemd = {
      services = {
        aide-init = {
          description = "Initialize AIDE database";
          wantedBy = [ "multi-user.target" ];
          after = [ "local-fs.target" ];

          stopIfChanged = false;
          restartIfChanged = false;
          reloadIfChanged = false;

          serviceConfig = {
            inherit (serviceConfig) Type Nice IOSchedulingClass;

            RemainAfterExit = true;
            TimeoutStartSec = 0;

            ExecStartPre = mkScript "aide-init-pre" ''
              ${mkdir} --parents ${cfg.libDir} ${cfg.logDir}
            '';

            ExecStart = mkScript "aide-init-start" ''
              if [ ! -f ${cfg.libDir}/aide.db.new ]
              then
                ${aide} --config=/etc/aide.conf --init
                ${mv} ${cfg.libDir}/aide.db.new ${cfg.libDir}/aide.db
                ${echo} "AIDE database successfully initialized and placed."
              else
                ${echo} "Error: Database creation failed."
                exit 1
              fi
            '';
          };
        };

        aide-check = {
          description = "Run AIDE integrity check";
          requires = [ "aide-init.service" ];
          after = [ "aide-init.service" ];

          serviceConfig = {
            inherit (serviceConfig) Type Nice IOSchedulingClass;

            ExecStart = mkScript "aide-check" ''
              ${aide} --config /etc/aide.conf --check | tee ${cfg.logDir}/aide-check-$(date +%Y%m%d-%H%M%S).log
            '';

            ExecStartPost = mkIf (cfg.alertEmail != null) (
              mkScript "aide-check-post" ''
                if [ -s ${cfg.logDir}/aide-check-*.log ]
                then
                    ${mail} -s "AIDE Report - $(hostname)" ${cfg.alertEmail} < ${cfg.logDir}/aide-check-*.log
                fi
              ''
            );
          };
        };

        aide-update = {
          description = "Update AIDE database";
          requires = [ "aide-init.service" ];
          after = [ "aide-init.service" ];

          serviceConfig = {
            inherit (serviceConfig) Type Nice IOSchedulingClass;

            ExecStart = mkScript "aide-update-start" "${aide} --config /etc/aide.conf --update";
            ExecStartPost = mkScript "aide-update-startpost" "${mv} ${cfg.libDir}/aide.db.new.gz ${cfg.libDir}/aide.db.gz";
          };
        };

        aide-metrics = mkIf false {
          description = "Collect AIDE metrics for Prometheus";
          after = [ "aide-check.service" ];

          serviceConfig = {
            Type = "oneshot";
            ExecStart = mkScript "aide-metrics" "";
            User = "root";
          };
        };

      };

      timers.aide-check = {
        description = "Periodic AIDE check";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = cfg.checkInterval;
          Persistent = true;
          OnBootSec = "45m";
          OnUnitActiveSec = "1w";
          RandomizedDelaySec = "45m";
        };
      };

      tmpfiles.rules = [
        "d ${cfg.libDir} 0700 root root -"
        "d ${cfg.logDir} 0700 root root -"
      ];
    };

  };
}
