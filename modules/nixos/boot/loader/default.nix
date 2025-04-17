{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool;

  cfg = config.boot.loader;
in
{
  imports = [
    ./grub
  ];

  options.boot.loader = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (!cfg.disableModule) {
    boot.loader = mkDefault {
      timeout = 3;
    };
  };
}
