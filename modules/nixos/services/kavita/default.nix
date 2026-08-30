{
  config,
  lib,
  lib',
  ...
}:
let
  inherit (lib) mkOption mkIf;
  inherit (lib.types) bool;
  inherit (lib'.flake.caddy) mkProxyOption;

  cfg = config.services.kavita;
in
{
  options.services.kavita = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };

    proxy = mkProxyOption {
      inherit (config.networking) naming;
      name = "kavita";
      upstream.port = cfg.port;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    services.kavita = { };

    services.caddy.proxies = [ cfg.proxy ];
  };
}
