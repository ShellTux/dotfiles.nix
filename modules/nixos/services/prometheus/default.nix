{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool;

  cfg = config.services.prometheus;
in
{
  options.services.prometheus = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    services.prometheus = {
      listenAddress = mkDefault "127.0.0.1";
    };

    programs.rust-motd.settings.service_status.Prometheus = "prometheus";
  };
}
