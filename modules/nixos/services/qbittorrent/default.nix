{
  config,
  lib,
  pkgs,
  lib',
  ...
}:
let
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool path nullOr;
  inherit (lib'.flake.caddy) mkProxyOption;

  cfg = config.services.qbittorrent;
in
{
  options.services.qbittorrent = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };

    proxy = mkProxyOption {
      inherit (config.server) domain;
      name = "qbittorrent";
      upstream.port = cfg.webuiPort;
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

    services.caddy.proxies = [ cfg.proxy ];

    programs.rust-motd.settings.service_status.Qbittorrent = "qbittorrent";

    systemd.tmpfiles.rules = [
      (mkIf (cfg.downloadPath != null) "d ${cfg.downloadPath} 0755 ${cfg.user} ${cfg.group} - -")
    ];

  };
}
