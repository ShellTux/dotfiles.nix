{ config, lib, ... }:
let
  inherit (builtins) map readFile concatStringsSep;
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool;

  cfg = config.programs.newsboat;
in
{
  options.programs.newsboat = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    programs.newsboat = mkDefault {
      autoReload = true;
      reloadTime = 15;

      extraConfig =
        [
          ./extra-config
          ./vim
          ./highlights
          ./macros
        ]
        |> map readFile
        |> concatStringsSep "\n";
    };
  };
}
