{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (builtins) length attrNames;
  inherit (lib)
    getExe
    getExe'
    mapAttrs'
    mkDefault
    mkIf
    mkOption
    nameValuePair
    ;
  inherit (lib.types)
    attrsOf
    bool
    str
    submodule
    package
    ;

  jobOptions = { name, ... }: {
    options = {
      watchPath = mkOption {
        type = str;
        example = "/Jellyfin";
        description = "The directory containing files to hash.";
      };

      databasePath = mkOption {
        type = str;
        default = "/var/lib/cksfv/${name}.sfv";
        description = "Where to save this specific CRC32 database file.";
      };

      interval = mkOption {
        type = str;
        default = "daily";
        example = "weekly";
        description = "How often to run this specific check (systemd Calendar expression).";
      };
    };
  };

  cksfv = getExe cfg.package;
  mkdir = getExe' pkgs.coreutils "mkdir";
  dirname = getExe' pkgs.coreutils "dirname";

  cfg = config.services.cksfv;
in
{
  options.services.cksfv = {
    enable = mkOption {
      type = bool;
      internal = true;
      description = "cksfv media integrity daemon";
      default = length (attrNames cfg.jobs) > 0;
    };

    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };

    package = mkOption {
      type = package;
      default = pkgs.cksfv;
      description = "The cksfv package to use.";
    };

    jobs = mkOption {
      type = attrsOf (submodule jobOptions);
      default = { };
      description = "Declarative cksfv monitoring jobs.";
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    services.cksfv = mkDefault { };

    environment.systemPackages = [ pkgs.cksfv ];

    systemd.services = mapAttrs' (
      name: job:
      nameValuePair "cksfv-${name}" {
        description = "cksfv CRC32 Media Integrity Scan for ${name}";
        after = [
          "network.target"
          "local-fs.target"
        ];
        requires = [ "local-fs.target" ];

        script = ''
          set -euo pipefail

          echo "=== Starting cksfv Integrity Scan [Job: ${name}] ==="
          echo "Scanning Path: ${job.watchPath}"
          echo "Database File: ${job.databasePath}"

          # Ensure the parent directory for the database exists
          ${mkdir} --parents "$(${dirname} "${job.databasePath}")"

          # If database exists, verify against it
          if [ -f "${job.databasePath}" ]
          then
            echo "--> Step 1: Checking existing files against database for modifications..."
            ${cksfv} -f "${job.databasePath}" || echo "!!! WARNING: Discrepancies found in ${name} database!"
          fi

          echo "--> Step 2: Updating database with current files..."
          cd "${job.watchPath}"

          # Generate the new CRC32 file cleanly using a temp file first
          ${cksfv} -r * > "${job.databasePath}.tmp"
          mv "${job.databasePath}.tmp" "${job.databasePath}"

          echo "=== [Job: ${name}] Scan complete. ==="
        '';

        serviceConfig = {
          Type = "oneshot";
          User = "root";
        };
      }
    ) cfg.jobs;
  };
}
