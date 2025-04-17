{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool;

  domain = "example.com";
  subdomain = "qbittorrent.${domain}";

  download-path = "/srv/downloads/qbittorent";

  cfg = config.services.qbittorrent;
in
{
  options.services.qbittorrent = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
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
          Downloads.SavePath = download-path;
        };
        BitTorrent.Session = {
          MaxActiveTorrents = 10;
        };
      };
      webuiPort = 9839;
    };

    services.caddy.virtualHosts = {
      "${subdomain}".extraConfig = ''
        encode zstd gzip

        reverse_proxy :${cfg.webuiPort |> toString} {
          header_up X-Real-IP {remote_host}
        }
      '';

      ":7003".extraConfig = ''
        import https
        import reverse-proxy 127.0.0.1 ${cfg.webuiPort |> toString}
      '';
    };

    systemd.tmpfiles.rules = [
      "d ${download-path} 0755 ${cfg.group} ${cfg.user}"
    ];

  };
}
