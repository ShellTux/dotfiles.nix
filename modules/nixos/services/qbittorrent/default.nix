{
  config,
  lib,
  pkgs,
  lib',
  ...
}:
let
  inherit (builtins) elem;
  inherit (lib)
    mkOption
    mkIf
    mkDefault
    removeSuffix
    ;
  inherit (lib.types) bool path nullOr;
  inherit (lib'.flake.networking) mkSiteOptions;

  cfg = config.services.qbittorrent;
in
{
  options.services.qbittorrent = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };

    site = mkSiteOptions {
      subdomain = "qbittorrent";
      inherit (config.networking) fqdnOrHostName localFqdn;
      description = "qBittorrent é um aplicativo cliente P2P multiplataforma, gratuito, livre e de código aberto para a rede BitTorrent.";
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    services.qbittorrent = {
      package = mkDefault pkgs.qbittorrent-nox;
      serverConfig = {
        Preferences = {
          # Alternative speed limits
          AltGlobalDLLimit = mkDefault 100; # KiB/s
          AltGlobalUPLimit = mkDefault 100; # KiB/s

          # Scheduler
          SchedulerEnabled = mkDefault true;
          SchedulerStartTime = mkDefault 480; # 08:00
          SchedulerEndTime = mkDefault 1200; # 20:00

          # Ignore slow torrents when applying queue limits
          QueueingIgnoreSlowTorrents = mkDefault true;
          SlowTorrentsDownloadRate = mkDefault 10; # KiB/s
          SlowTorrentsUploadRate = mkDefault 10; # KiB/s
          SlowTorrentsInactivityTimer = mkDefault 60; # seconds

          # Torrent queueing
          MaxActiveDownloads = mkDefault 5;
          MaxActiveUploads = mkDefault 10;
          MaxActiveTorrents = mkDefault 30;

          Connection = mkIf config.services.i2pd.enable {
            EnableI2P = true;
            I2PAddress = mkDefault "127.0.0.1";
            I2PPort = mkDefault config.services.i2pd.settings.sam.port;
          };

          LegalNotice.Accepted = true;
          WebUI = {
            AlternativeUIEnabled = true;
            HostHeaderValidation = mkDefault true;
            RootFolder = "${pkgs.vuetorrent}/share/vuetorrent";
            CSRFProtection = mkDefault true;
            ClickjackingProtection = mkDefault true;
            RefreshInterval = mkDefault 1000;

            Username = "admin";
            # generate password with:
            # nix run git+https://codeberg.org/feathecutie/qbittorrent_password -- -p "$(read -s PASSWORD; echo $PASSWORD)"
            # Password_PBKDF2 = "<hash password>";
          };

          BitTorrent.Session.MaxActiveTorrents = 10;
        };

      };
      webuiPort = mkDefault 9839;
    };

    services = {
      caddy.virtualHosts = mkIf (cfg.site.reverse-proxy == "caddy") {
        "${cfg.site.fqdn}" = mkIf (elem "public" cfg.site.exposure) {
          extraConfig = ''
            import tls-public
            import encoding
            import coraza
            import reverse-proxy 127.0.0.1:${toString cfg.webuiPort}
          '';
        };

        "${cfg.site.localFqdn}" = mkIf (elem "local" cfg.site.exposure) {
          extraConfig = ''
            import tls-local
            import encoding
            import reverse-proxy 127.0.0.1:${toString cfg.webuiPort}
          '';
        };
      };

      homepage-dashboard.service-templates.qbittorrent = {
        display = "Qbittorrent";
        inherit (cfg.site)
          description
          href
          ping
          siteMonitor
          ;
        icon = "qbittorrent.png";

        widget = mkIf false {
          url = cfg.site.href;
          type = "qbittorrent";
          enableLeechProgress = true; # optional, defaults to false
          enableLeechSize = true; # optional, defaults to false
          key = "{{HOMEPAGE_VAR_QBITORRENT_KEY}}";
        };
      };
    };

    programs.rust-motd.settings.service_status.Qbittorrent =
      removeSuffix ".service" config.systemd.services.qbittorrent.name;

  };
}
