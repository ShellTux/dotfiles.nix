{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool str path;

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

      default = "deluge.${config.server.domain}";
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

    services.caddy.virtualHosts = {
      "${cfg.subdomain}".extraConfig = ''
        encode zstd gzip

        reverse_proxy :${cfg.web.port |> toString} {
          header_up X-Real-IP {remote_host}
        }
      '';

      ":${toString config.server.reverse-proxy.port.deluge}".extraConfig = ''
        import https
        import reverse-proxy 127.0.0.1 ${cfg.web.port |> toString}
      '';
    };

    programs.rust-motd.settings.service_status.Deluge = "deluge";

    systemd.tmpfiles.rules = [
      (mkIf (cfg.downloadPath != null) "d ${cfg.downloadPath} 0755 ${cfg.user} ${cfg.group} - -")
    ];
  };
}
