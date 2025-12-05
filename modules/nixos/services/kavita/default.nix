{
  config,
  lib,
  flake-lib,
  ...
}:
let
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool str port;
  inherit (flake-lib.caddy) genVirtualHosts;

  cfg = config.services.kavita;
in
{
  options.services.kavita = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };

    subdomain = mkOption {
      description = "subdomain";
      type = str;
      default = "kavita";
    };

    reverse-proxy.port = {
      external = mkOption {
        description = "Reverse Proxy external port";
        type = port;
        default = 9911;
      };

      internal = mkOption {
        description = "Reverse Proxy internal port";
        type = port;
        default = cfg.settings.Port;
      };
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    services.kavita = { };

    services.caddy.virtualHosts = genVirtualHosts {
      inherit (cfg) subdomain reverse-proxy;
    };
  };
}
