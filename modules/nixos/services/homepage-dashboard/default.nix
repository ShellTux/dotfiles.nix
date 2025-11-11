{
  config,
  lib,
  ...
}:
let
  inherit (builtins) toString;
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool;

  cfg = config.services.homepage-dashboard;
in
{
  options.services.homepage-dashboard = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
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
          inherit (config.services)
            jellyfin
            vaultwarden
            kavita
            qbittorrent
            deluge
            ;
          inherit (config.server) reverse-proxy;
        in
        [
          {
            Media = [
              (import ./jellyfin.nix jellyfin.enable jellyfin.port reverse-proxy.port.jellyfin)
              (import ./kavita.nix kavita.enable kavita.port reverse-proxy.port.kavita)
            ];
          }
          {
            Download = [
              (import ./qbittorrent.nix qbittorrent.enable qbittorrent.webuiPort reverse-proxy.port.qbittorrent)
              (import ./deluge.nix deluge.enable deluge.web.port reverse-proxy.port.deluge)
            ];
          }
          {
            Services = [
              (import ./vaultwarden.nix vaultwarden.enable vaultwarden.config.ROCKET_PORT
                reverse-proxy.port.vaultwarden
              )
            ];
          }
        ];

    };

    services.caddy.virtualHosts.":${toString config.server.reverse-proxy.port.homepage-dashboard}".extraConfig =
      ''
        import https
        import reverse-proxy 127.0.0.1 ${cfg.listenPort |> toString}
      '';
  };
}
