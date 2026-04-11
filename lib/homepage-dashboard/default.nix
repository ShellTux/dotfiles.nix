{ ... }:
{
  genService =
    {
      enable,
      reverse-proxy, # AttrSet { .port = { external, internal }; }
      service,
      subdomain,
      domain ? "home",
      widgetEnabled ? false,
    }:
    let
      inherit (reverse-proxy.port) external internal;

      href = "https://${subdomain}.${domain}:${toString external}";

      serviceName =
        {
          changedetection-io = "ChangeDetectionIO";
          deluge = "Deluge";
          forgejo = "Forgejo";
          grafana = "Grafana";
          immich = "Immich";
          jellyfin = "Jellyfin";
          kavita = "Kavita";
          photoprism = "Photoprism";
          qbittorrent = "Qbittorrent";
          vaultwarden = "Vaultwarden";
        }
        .${service};

      description =
        {
          changedetection-io = "Monitor and detect website changes with alerts. Easily track website changes.";
          deluge = "Deluge is a lightweight, Free Software, cross-platform BitTorrent client.";
          forgejo = "Forgejo is a self-hosted lightweight software forge.";
          grafana = "Grafana is a visualization tool for creating real-time monitoring dashboards from various data sources.";
          immich = "High performance self-hosted photo and video management solution.";
          jellyfin = "Free media server for organizing and streaming your personal media.";
          kavita = "Kavita is an open-source app for managing and reading manga, comics, and ebooks.";
          photoprism = "PhotoPrism® is an AI-Powered Photos App for the Decentralized Web. It makes use of the latest technologies to tag and find pictures automatically without getting in your way. You can run it at home, on a private server, or in the cloud.";
          qbittorrent = "Open-source torrent client for downloading and sharing files.";
          vaultwarden = "Self-hosted password manager for securely storing passwords and notes.";
        }
        .${service};

      widgetConfig =
        if widgetEnabled then
          {
            widget =
              {
                jellyfin = {
                  type = "jellyfin";
                  url = href;
                  key = "{{HOMEPAGE_VAR_JELLYFIN_KEY}}";
                  enableBlocks = true; # optional, defaults to false
                  enableNowPlaying = true; # optional, defaults to true
                  enableUser = true; # optional, defaults to false
                  enableMediaControl = false; # optional, defaults to true
                  showEpisodeNumber = true; # optional, defaults to false
                  expandOneStreamToTwoRows = false; # optional, defaults to true
                };
                immich = {
                  type = "immich";
                  url = href;
                  key = "{{HOMEPAGE_VAR_IMMICH_KEY}}";
                  version = 2;
                };
                changedetection-io = {
                  type = "changedetectionio";
                  url = href;
                  key = "{{HOMEPAGE_VAR_CHANGEDETECTIONIO_KEY}}";
                  version = 2;
                };
              }
              .${service};
          }
        else
          { };

      icons = {
        changedetection-io = "changedetection.png";
      };

      icon = if icons ? ${service} then icons.${service} else "${service}.png";
    in
    if enable then
      {
        ${serviceName} = {
          inherit icon description href;
          ping = "http://127.0.0.1:${toString internal}";
        }
        // widgetConfig;
      }
    else
      { };
}
