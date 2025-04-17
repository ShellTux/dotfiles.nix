{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption mkIf;
  inherit (lib.types) bool;

  cfg = config.programs.btop;
in
{
  options.programs.btop = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    programs.btop = {
      settings = {
        proc_sorting = "cpu lazy";
        update_ms = 200;
        vim_keys = true;
      };
    };
  };
}
