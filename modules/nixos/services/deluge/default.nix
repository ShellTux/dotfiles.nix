{
  config,
  lib,
  pkgs,
  flake-lib,
  ...
}:
let
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types)
    bool
    str
    path
    port
    ;
  inherit (flake-lib.caddy) genVirtualHosts;

  cfg = config.services.deluge;
in
{
  options.services.deluge = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };

    subdomain = mkOption {
      description = "Subdomain";
      type = str;
      default = "deluge";
    };

    reverse-proxy.port = {
      external = mkOption {
        description = "Reverse Proxy external port";
        type = port;
        default = 9906;
      };

      internal = mkOption {
        description = "Reverse Proxy internal port";
        type = port;
        default = cfg.web.port;
      };
    };

    downloadPath = mkOption {
      description = "Download path";
      type = path;
      default = "${cfg.dataDir}/Downloads";
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    services.deluge = mkDefault {
      extraPackages = [
        pkgs.unzip
        pkgs.gnutar
        pkgs.xz
        pkgs.bzip2
      ];

      web.enable = true;
    };

    services.caddy.virtualHosts = genVirtualHosts {
      inherit (cfg) subdomain reverse-proxy;
    };

    programs.rust-motd.settings.service_status.Deluge = "deluge";

    systemd.tmpfiles.rules = [
      (mkIf (cfg.downloadPath != null) "d ${cfg.downloadPath} 0755 ${cfg.user} ${cfg.group} - -")
    ];
  };
}
