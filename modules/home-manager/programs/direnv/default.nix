{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption mkIf;
  inherit (lib.types) bool;

  cfg = config.programs.direnv;
in
{
  options.programs.direnv = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    programs.direnv = {
      config.global.hide_env_diff = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };
  };
}
