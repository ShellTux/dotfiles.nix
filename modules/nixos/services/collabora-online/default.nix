{
  config,
  lib,
  lib',
  ...
}:
let
  inherit (lib)
    mkDefault
    mkIf
    mkOption
    optional
    ;
  inherit (lib.types) bool;
  inherit (lib'.flake.caddy) mkProxyOption;

  cfg = config.services.collabora-online;
in
{
  options.services.collabora-online = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };

    proxy = mkProxyOption {
      inherit (config.networking) naming;
      name = "collabora";
      upstream = {
        host = "[::1]";
        port = cfg.port;
      };
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    services.collabora-online = {
      settings = {

        ssl = {
          enable = false;
          termination = true;
        };

        net = {
          listen = "loopback";
          post_allow.host = [
            "127.0.0.1"
            "::1"
          ];
        };

        storage.wopi = {
          "@allow" = true;
          host = [ config.services.nextcloud.hostName ];
        };

        server_name = mkDefault cfg.proxy.computedFqdn;
      };
    };

    services.caddy.proxies = optional cfg.proxy.enable cfg.proxy;
    programs.rust-motd.settings.service_status.Collabora = "collabora-online";
  };
}
