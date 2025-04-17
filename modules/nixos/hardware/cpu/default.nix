{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool;

  cfg = config.hardware.cpu;
in
{
  options.hardware.cpu = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (!cfg.disableModule) {
    hardware.cpu = {
      amd.updateMicrocode = mkDefault (cfg.brand == "amd");
      intel.updateMicrocode = mkDefault (cfg.brand == "intel");
    };
  };
}
