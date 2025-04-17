{
  config,
  lib,
  ...
}:
let
  inherit (builtins) toString;
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool;

  domain = "example.com";

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

      settings = {
        title = "NixOS Home Server";
        background = {
          image = "https://images.unsplash.com/photo-1502790671504-542ad42d5189?auto=format&fit=crop&w=2560&q=80";
          blur = "sm";
          saturate = "70";
          brightness = "60";
          opacity = "50";
        };
        theme = "dark";
        color = "slate";
        headerStyle = "underlined";
        layout = {
          Media = {
            style = "row";
            columns = 2;
          };

          Download = {
            style = "row";
            columns = 2;
          };

          Services = {
            style = "row";
            columns = 4;
          };
        };
        language = "pt";
      };

      services = [
        {
          Media =
            [
              (mkIf config.services.jellyfin.enable {
                Jellyfin = {
                  icon = "jellyfin.png";
                  href = "https://jellyfin.${domain}";
                  # ping = "";
                  description = "Free media server for organizing and streaming your personal media.";
                  # widget = {
                  #   type = "jellyfin";
                  #   url = "";
                  #   key = "apikey";
                  #   enableBlocks = true;
                  #   enableNowPlaying = true;
                  #   enableUser = false;
                  #   expandOneStreamToTwoRows = false;
                  # };
                };
              })
            ]
            ++ [
              (mkIf config.services.kavita.enable {
                Kavita = {
                  icon = "kavita.png";
                  href = "https://kavita.${domain}";
                  # ping = "";
                  description = "Kavita is an open-source app for managing and reading manga, comics, and ebooks.";
                  # widget = {
                  #   type = "kavita";
                  #   url = "";
                  #   key = "";
                  # };
                };
              })
            ];
        }
        {
          Download = [
            (mkIf config.services.qbittorrent.enable {
              qBittorrent = {
                icon = "qbittorrent.png";
                href = "https://qbittorrent.${domain}";
                # ping = "";
                description = "Open-source torrent client for downloading and sharing files.";
                # widget = {
                #   type = "qbittorrent";
                #   url = "todo";
                #   username = cfg.serverConfig.Preferences.WebUI.Username;
                #   password = cfg.serverConfig.Preferences.WebUI.Password_PBKDF2;
                # };
              };
            })
          ];
        }
        {
          Services =
            [
              (mkIf config.services.vaultwarden.enable {
                Vaultwarden = {
                  icon = "vaultwarden.png";
                  href = "https://vaultwarden.${domain}";
                  # ping = "";
                  description = "Self-hosted password manager for securely storing passwords and notes.";
                };
              })
            ]
            ++ [
              (mkIf config.services.forgejo.enable {
                Forgejo = {
                  icon = "forgejo.png";
                  href = "https://forgejo.${domain}";
                  description = "Forgejo is an open-source self-hosted platform for managing Git repositories and collaboration.";
                };
              })
            ]
            ++ [
              (mkIf config.services.paperless.enable {
                Paperless-ngx = {
                  icon = "paperless-ngx.png";
                  href = "https://paperless.${domain}";
                  # ping = "";
                  description = "Paperless-ngx is an open-source system for digitizing, organizing, and managing scanned documents.";
                  # widget = {
                  #   type = "paperlessngx";
                  #   url = "";
                  #   key = "apikey";
                  # };
                };
              })
            ]
            ++ [
              (mkIf config.services.stirling-pdf.enable {
                Stirling-pdf = {
                  icon = "stirling-pdf.png";
                  href = "https://pdf.${domain}";
                  # ping = "";
                  description = "Stirling-PDF is an open-source library for creating and manipulating PDF documents.";
                };
              })
            ];
        }
      ];

      widgets = [
        {
          resources = {
            cpu = true;
            disk = "/";
            memory = true;
            uptime = true;
          };
        }
        {
          search = {
            provider = "duckduckgo";
            target = "_blank";
          };
        }
      ];

      bookmarks = [
        {
          Developer = [
            {
              Github = [
                {
                  icon = "si-github";
                  href = "https://github.com/";
                }
              ];
            }
            {
              "Nixos Search" = [
                {
                  icon = "si-nixos";
                  href = "https://search.nixos.org/packages";
                }
              ];
            }
            {
              "Nixos Wiki" = [
                {
                  icon = "si-nixos";
                  href = "https://nixos.wiki/";
                }
              ];
            }
            {
              "MyNixOS" = [
                {
                  icon = "si-nixos";
                  href = "https://mynixos.com";
                }
              ];
            }
          ];
        }
      ];

    };

    services.caddy.virtualHosts.":7000".extraConfig = ''
      import https
      import reverse-proxy 127.0.0.1 ${cfg.listenPort |> toString}
    '';
  };
}
