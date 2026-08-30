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

  cfg = config.services.vaultwarden;
in
{
  options.services.vaultwarden = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };

    proxy = mkProxyOption {
      inherit (config.networking) naming;
      name = "vaultwarden";
      upstream.port = cfg.config.ROCKET_PORT;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    services.vaultwarden = {
      backupDir = "/var/backup/vaultwarden";
      config = {
        # DOMAIN = "https://${cfg.proxy.computedDomain}";
        ROCKET_ADDRESS = "127.0.0.1";
        ROCKET_PORT = 8222;
      };
    };

    programs.rust-motd.settings.service_status.Vaultwarden = "vaultwarden";

    services.caddy.proxies = [ cfg.proxy ];
  };
}
