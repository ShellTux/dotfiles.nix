{
  config,
  lib,
  flake-lib,
  ...
}:
let
  inherit (lib)
    mkOption
    mkIf
    mkDefault
    mkEnableOption
    pipe
    filterAttrs
    mapAttrsToList
    ;
  inherit (lib.types) bool str port;
  inherit (flake-lib.homepage-dashboard) genService;
  inherit (flake-lib.caddy) genVirtualHosts;

  cfg = config.services.homepage-dashboard;
in
{
  options.services.homepage-dashboard = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };

    subdomain = mkOption {
      description = "subdomain";
      type = str;
      default = "homepage";
    };

    reverse-proxy.port = {
      external = mkOption {
        description = "Reverse Proxy external port";
        type = port;
        default = 9902;
      };

      internal = mkOption {
        description = "Reverse Proxy internal port";
        type = port;
        default = cfg.listenPort;
      };
    };

    widget = {
      changedetection-io = mkEnableOption "Wether to enable changedetection-io widget";
      deluge = mkEnableOption "Wether to enable deluge widget";
      forgejo = mkEnableOption "Wether to enable forgejo widget";
      immich = mkEnableOption "Wether to enable immich widget";
      jellyfin = mkEnableOption "Wether to enable jellyfin widget";
      kavita = mkEnableOption "Wether to enable kavita widget";
      photoprism = mkEnableOption "Wether to enable photoprism widget";
      qbittorrent = mkEnableOption "Wether to enable qbittorrent widget";
      vaultwarden = mkEnableOption "Wether to enable vaultwarden widget";
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    services.homepage-dashboard = mkDefault {
      allowedHosts = "*";

      settings = import ./settings.nix;
      widgets = import ./widgets.nix;
      bookmarks = import ./bookmarks.nix;

      services =
        let
          genSection = section: services: {
            ${section} = pipe services [
              (filterAttrs (sName: sConfig: sConfig.enable))
              (mapAttrsToList (
                service: serviceConfig: {
                  inherit service;
                  inherit (serviceConfig) enable subdomain reverse-proxy;

                  widgetEnabled = cfg.widget.${service};
                }
              ))
              (map genService)
            ];
          };
        in
        [
          (genSection "Media" {
            inherit (config.services)
              jellyfin
              kavita
              photoprism
              immich
              ;
          })
          (genSection "Download" { inherit (config.services) qbittorrent deluge; })
          (genSection "Services" { inherit (config.services) vaultwarden forgejo changedetection-io; })
        ];
    };

    programs.rust-motd.settings.service_status.Homepage = "homepage-dashboard";

    services.caddy.virtualHosts = genVirtualHosts {
      inherit (cfg) subdomain reverse-proxy;
    };
  };
}
