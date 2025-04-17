{ config, lib, ... }:
let
  inherit (builtins) readFile fromTOML;
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool;

  cfg = config.programs.oh-my-posh;
in
{
  options.programs.oh-my-posh = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    programs.oh-my-posh = mkDefault {
      enableBashIntegration = true;
      enableZshIntegration = true;

      settings = readFile ./oh-my-posh.toml |> fromTOML;
    };
  };
}
