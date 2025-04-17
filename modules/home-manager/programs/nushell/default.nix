{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool;

  cfg = config.programs.nushell;
in
{
  options.programs.nushell = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    programs.nushell = mkDefault {
      plugins = [
        pkgs.nushellPlugins.formats
        pkgs.nushellPlugins.gstat
        pkgs.nushellPlugins.polars
        pkgs.nushellPlugins.query
      ];

      settings = {

      };
    };
  };
}
