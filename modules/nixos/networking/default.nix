{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool str nullOr;

  cfg = config.networking;
in
{
  imports = [
    ./networkmanager
    ./stevenblack
    ./wireguard
  ];

  options.networking = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };

    naming = {
      domain = mkOption {
        description = "The root domain name used to access services from the public internet. If null, external public access features will be disabled.";
        type = nullOr str;
        default = null;
        example = "duckdns.org";
      };

      localDomain = mkOption {
        description = "The local domain name used for internal network routing. Defaults to using the system's hostname under the '.home' local top-level domain.";
        type = nullOr str;
        default = "home";
        example = "local";
      };

      localHostName = mkOption {
        description = "The hostname used exclusively within the local network. Useful if you want the machine to present a different identity internally than its public one.";
        type = str;
        default = cfg.hostName;
        example = "nas-local";
      };

      hostName = mkOption {
        description = "The primary hostname of the server, used for both public identification and system naming configurations.";
        type = str;
        default = cfg.hostName;
        example = "webserver";
      };

      localfqdn = mkOption {
        internal = true;
        description = "Internal read-only option that computes the Fully Qualified Domain Name for the local network by joining localHostName and localDomain.";
        type = str;
        default = "${cfg.naming.localHostName}.${cfg.naming.localDomain}";
      };

      fqdn = mkOption {
        internal = true;
        description = "Internal read-only option that computes the public Fully Qualified Domain Name by joining hostName and domain (if defined).";
        type = nullOr str;
        default = if cfg.naming.domain != null then "${cfg.naming.hostName}.${cfg.naming.domain}" else null;
      };

      isPublic = mkOption {
        internal = true;
        default = cfg.naming.domain != null;
      };
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    networking = mkDefault { };
  };
}
