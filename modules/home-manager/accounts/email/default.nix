{ config, lib, ... }:
let
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool;

  cfg = config.accounts.email;
in
{
  options.accounts.email = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (!cfg.disableModule) {
    accounts.email = mkDefault {
      maildirBasePath = "Mail";
    };
  };
}
