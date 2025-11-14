{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types)
    bool
    str
    path
    nullOr
    ;

  cfg = config.services.qbittorrent;
in
{
  options.services.qbittorrent = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };

    subdomain = mkOption {
      description = "Subdomain";
      type = str;

      default = "qbittorrent.${config.server.domain}";
    };

    downloadPath = mkOption {
      description = "Qbittorrent download path";
      type = nullOr path;
      default = null;
      example = "/srv/downloads/qbittorrent";
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    services.qbittorrent = mkDefault {
      package = pkgs.qbittorrent-nox;
      serverConfig = {
        Preferences = {
          LegalNotice.Accepted = true;
          WebUI = {
            AlternativeUIEnabled = true;
            HostHeaderValidation = false;
            RootFolder = "${pkgs.vuetorrent}/share/vuetorrent";

            Username = "admin";
            # generate password with:
            # nix run git+https://codeberg.org/feathecutie/qbittorrent_password -- -p "$(read -s PASSWORD; echo $PASSWORD)"
            # Password_PBKDF2 = "<hash password>";
          };
          Downloads.SavePath = mkIf (cfg.downloadPath != null) cfg.downloadPath;
        };
        BitTorrent.Session = {
          MaxActiveTorrents = 10;
        };
      };
      webuiPort = 9839;
    };

    services.caddy.virtualHosts = {
      "${cfg.subdomain}".extraConfig = ''
        encode zstd gzip

        reverse_proxy :${cfg.webuiPort |> toString} {
          header_up X-Real-IP {remote_host}
        }
      '';

      ":${toString config.server.reverse-proxy.port.qbittorrent}".extraConfig = ''
        import https
        import reverse-proxy 127.0.0.1 ${cfg.webuiPort |> toString}
      '';
    };

    programs.rust-motd.settings.service_status.Qbittorrent = "qbittorrent";

    systemd.tmpfiles.rules = [
      (mkIf (cfg.downloadPath != null) "d ${cfg.downloadPath} 0755 ${cfg.group} ${cfg.user}")
    ];

  };
}
