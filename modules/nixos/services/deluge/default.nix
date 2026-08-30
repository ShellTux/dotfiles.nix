{
  config,
  lib,
  pkgs,
  lib',
  ...
}:
let
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool path;
  inherit (lib'.flake.caddy) mkProxyOption;

  cfg = config.services.deluge;
in
{
  options.services.deluge = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };

    proxy = mkProxyOption {
      inherit (config.networking) naming;
      name = "deluge";
      upstream.port = cfg.web.port;
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

    services.caddy.proxies = [ cfg.proxy ];

    programs.rust-motd.settings.service_status.Deluge = "delugeweb";

    systemd.tmpfiles.rules = [
      (mkIf (cfg.downloadPath != null) "d ${cfg.downloadPath} 0755 ${cfg.user} ${cfg.group} - -")
    ];
  };
}
