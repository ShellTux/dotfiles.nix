{
  config,
  lib,
  lib',
  ...
}:
let
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool;
  inherit (lib'.flake.caddy) mkProxyOption;

  cfg = config.services.homepage-dashboard;
in
{
  options.services.homepage-dashboard = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };

    proxy = mkProxyOption {
      inherit (config.networking) naming;
      name = "home";
      upstream.port = cfg.listenPort;
      host.rootRedir = true;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    services.homepage-dashboard = {
      allowedHosts = "*";

      bookmarks = mkDefault [
        {
          Developer = [
            {
              Github = [
                {
                  abbr = "GH";
                  href = "https://github.com/";
                }
              ];
            }
          ];
        }
        {
          Entertainment = [
            {
              YouTube = [
                {
                  abbr = "YT";
                  href = "https://youtube.com/";
                }
              ];
            }
          ];
        }
      ];

      widgets = mkDefault [
        {
          resources = {
            cpu = true;
            disk = "/";
            memory = true;
          };
        }
        {
          search = {
            provider = "duckduckgo";
            target = "_blank";
          };
        }
      ];
    };

    programs.rust-motd.settings.service_status.Homepage = "homepage-dashboard";

    services.caddy.proxies = [ cfg.proxy ];
  };
}
