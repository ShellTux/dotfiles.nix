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

  sops = {
    owner = "onlyoffice";
    group = "onlyoffice";
    mode = "0400";

    # Restart the service when the secret changes
    restartUnits = [ "onlyoffice-docservice.service" ];
  };

  cfg = config.services.onlyoffice;
in
{
  options.services.onlyoffice = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };

    proxy = mkProxyOption {
      inherit (config.networking) naming;
      name = "onlyoffice";
      upstream.port = cfg.port;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    services.onlyoffice = {
      jwtSecretFile = mkDefault config.sops.secrets."services/onlyoffice/jwtSecretFile".path;
      securityNonceFile = mkDefault config.sops.secrets."services/onlyoffice/securityNonceFile".path;
    };

    services.caddy.proxies = optional cfg.proxy.enable cfg.proxy;

    programs.rust-motd.settings.service_status.OnlyOffice = "onlyoffice";

    sops.secrets = {
      "services/onlyoffice/jwtSecretFile" = sops;
      "services/onlyoffice/securityNonceFile" = sops // {
        group = "nginx";
        mode = "0440";
      };
    };
  };
}
