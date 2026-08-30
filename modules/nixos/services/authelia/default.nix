{
  config,
  lib,
  lib',
  ...
}:
let
  inherit (lib)
    mapAttrs'
    mkDefault
    mkIf
    mkOption
    nameValuePair
    pipe
    ;
  inherit (lib.types) bool;
  inherit (lib'.flake.caddy) mkProxyOption;

  cfg = config.services.authelia;
in
{
  options.services.authelia = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };

    proxy = mkProxyOption {
      inherit (config.networking) naming;
      name = "auth";
      upstream.port = 9091;
    };
  };

  config = mkIf (!cfg.disableModule) {
    services.authelia = mkDefault { };

    services.caddy.proxies = [ cfg.proxy ];

    programs.rust-motd.settings.service_status = mapAttrs' (
      _: { name, user, ... }: nameValuePair "Authelia ${name}" user
    ) cfg.instances;
  };
}
