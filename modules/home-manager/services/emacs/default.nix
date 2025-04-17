{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool;

  cfg = config.services.emacs;
in
{
  options.services.emacs = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    services.emacs = mkDefault {
      client.enable = true;
      package = pkgs.emacs-pgtk;
      socketActivation.enable = true;
    };
  };
}
