{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool;

  cfg = config.networking.stevenblack;
in
{
  options.networking.stevenblack = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (!cfg.disableModule) {
    networking.stevenblack = mkDefault {
      enable = true;

      block = [
        "fakenews"
        "gambling"
      ];
    };
  };
}
