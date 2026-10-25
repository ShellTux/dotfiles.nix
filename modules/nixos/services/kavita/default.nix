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
    removeSuffix
    ;
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
      upstream.port = cfg.settings.Port;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    services.kavita = {
      tokenKeyFile = mkDefault config.sops.secrets."services/kavita/TokenKey".path;
    };

    services.caddy.proxies = optional cfg.proxy.enable cfg.proxy;

    programs.rust-motd.settings.service_status.Kavita =
      removeSuffix ".service" config.systemd.services.kavita.name;

    users = {
      groups.media = { };
      users."${cfg.user}".extraGroups = [ config.users.groups.media.name ];
    };

    sops.secrets."services/kavita/TokenKey" = {
      owner = cfg.user;
      mode = "0400";
    };
  };
}
