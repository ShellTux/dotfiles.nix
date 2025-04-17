{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool;

  cfg = config.networking.networkmanager;
in
{
  imports = [
    ./dispatcherScripts
  ];

  options.networking.networkmanager = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    networking.networkmanager = mkDefault {
      # TODO: Maybe don't default enable wifi powersave for desktop machines
      wifi.powersave = true;
    };
  };
}
