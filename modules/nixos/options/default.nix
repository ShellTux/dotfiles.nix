{ lib, ... }:
let
  inherit (lib) mkOption;
  inherit (lib.types) str port;
in
{
  options.server = {
    domain = mkOption {
      description = "The primary domain for the server. This domain is used to identify the server on the network and is essential for setting up web services, including web applications and APIs. It is also important for managing SSL/TLS certificates and DNS configurations. Ensure the domain is registered and points to the server's IP address.";
      type = str;
      default = "example.com";
    };

    local-domain = mkOption {
      description = "A reserved domain name intended for local network (LAN) use. This domain is useful for internal services and applications that do not require external access.";
      type = str;
      default = "example.com";
    };

    reverse-proxy.port = {
      homepage-dashboard = mkOption {
        description = "The port used for the reverse proxy to access the homepage dashboard. This allows users to reach the dashboard services through the specified port.";
        type = port;
        default = 9902;
      };

      vaultwarden = mkOption {
        description = "The port designated for reverse proxy access to Vaultwarden services, enabling secure password management through the specified port.";
        type = port;
        default = 9903;
      };

      jellyfin = mkOption {
        description = "The port allocated for reverse proxy connections to Jellyfin, facilitating media streaming from the specified service.";
        type = port;
        default = 9904;
      };

      qbittorrent = mkOption {
        description = "The port assigned for reverse proxy access to qBittorrent, allowing easy management of torrent downloads through the specified port.";
        type = port;
        default = 9905;
      };

      deluge = mkOption {
        description = "The port assigned for reverse proxy access to deluge, allowing easy management of torrent downloads through the specified port.";
        type = port;
        default = 9906;
      };

      photoprism = mkOption {
        description = "The port assigned for reverse proxy access to photoprism, allowing easy management of torrent downloads through the specified port.";
        type = port;
        default = 9907;
      };

      immich = mkOption {
        description = "The port assigned for reverse proxy access to immich";
        type = port;
        default = 9908;
      };
    };
  };
}
