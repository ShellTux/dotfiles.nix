{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf mkDefault;

  cfg = config.services.pipewire;
in
{
  config = mkIf (cfg.enable && !cfg.disableModule) {
    services.pipewire.extraConfig.pipewire."92-low-latency" = mkDefault {
      context.properties = {
        default.clock.rate = 48000;
        default.clock.quantum = 32;
        default.clock.min-quantum = 32;
        default.clock.max-quantum = 32;
      };
    };
  };
}
