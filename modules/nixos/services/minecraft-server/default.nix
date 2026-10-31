{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool;

  cfg = config.services.minecraft-server;
in
{
  options.services.minecraft-server = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    services.minecraft-server = {
      eula = mkDefault true;
      jvmOpts = mkDefault "-Xms4096M -Xmx8192M -XX:+UseG1GC";
    };
  };
}
