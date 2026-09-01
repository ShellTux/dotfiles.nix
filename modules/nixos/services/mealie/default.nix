{
  config,
  lib,
  lib',
  ...
}:
let
  inherit (lib)
    mkOption
    mkIf
    mkDefault
    optional
    ;
  inherit (lib.types) bool;
  inherit (lib'.flake.caddy) mkProxyOption;

  cfg = config.services.mealie;
in
{
  options.services.mealie = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };

    proxy = mkProxyOption {
      inherit (config.networking) naming;
      name = "mealie";
      upstream.port = cfg.port;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    services.mealie = {
      settings = {
        listenAdress = mkDefault "127.0.0.1";
      };
    };

    services.caddy.proxies = optional cfg.proxy.enable cfg.proxy;

    programs.rust-motd.settings.service_status.Mealie = "mealie";
  };
}
