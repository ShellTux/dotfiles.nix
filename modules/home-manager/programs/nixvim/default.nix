{ config, lib, ... }:
let
  inherit (lib) mkOption mkIf;
  inherit (lib.types) bool;

  cfg = config.programs.nixvim;
in
{
  options.programs.nixvim = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) { };
}
