{ inputs, ... }:
let
  inherit (inputs.nixpkgs.lib)
    pipe
    filterAttrs
    mapAttrsToList
    concatStringsSep
    ;
in
{
  hyprland = {
    windowrule =
      let
        effect = effect: match: "${effect}, ${match}";
      in
      {
        anonymous =
          {
            match ? {
              class = null;
            },
            effects ? {
              idle_inhibit = null;
            },
          }:
          concatStringsSep ", " (
            (pipe match [
              (filterAttrs (_: v: v != null))
              (mapAttrsToList (k: v: "match:${k} ${v}"))
            ])
            ++ (pipe effects [
              (filterAttrs (_: v: v != null))
              (mapAttrsToList (k: v: "${k} ${v}"))
            ])
          );

        float = effect "float";
        idleinhibit = mode: rule: "idleinhibit ${mode}, ${rule}";
        noborder = effect "noborder";
        opaque = effect "opaque";
        pin = effect "pin";
        size = width: height: effect "size ${width} ${height}";
        workspace = number: effect "workspace ${toString number}";
      };
  };

  nginx.genVirtualHosts =
    {
      subdomain,
      reverse-proxy, # AttrSet { .port = { external, internal }; }
    }:
    let
      inherit (reverse-proxy.port) external internal;
    in
    {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString internal}";
      };
    };

  caddy.genVirtualHosts =
    {
      subdomain,
      domain ? "home",
      reverse-proxy, # AttrSet { .port = { external, internal }; }
    }:
    let
      inherit (reverse-proxy.port) external internal;
    in
    {
      # "${subdomain}.${domain}".extraConfig = ''
      #   encode zstd gzip
      #
      #   reverse_proxy :${toString external} {
      #     header_up X-Real-IP {remote_host}
      #   }
      # '';

      ":${toString external}".extraConfig = ''
        encode zstd gzip

        import https
        import reverse-proxy 127.0.0.1 ${toString internal}
      '';
    };

  homepage-dashboard.genService =
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
          deluge = "Deluge";
          forgejo = "Forgejo";
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
          immich = "High performance self-hosted photo and video management solution.";
          forgejo = "Forgejo is a self-hosted lightweight software forge.";
          deluge = "Deluge is a lightweight, Free Software, cross-platform BitTorrent client.";
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
              }
              .${service};
          }
        else
          { };

      icon = "${service}.png";
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

  double = a: a * 2;
}
