{ config, lib, ... }:
let
  inherit (builtins) readFile;
  inherit (lib) mkOption mkIf;
  inherit (lib.types) bool;

  cfg = config.programs.wezterm;
in
{
  options.programs.wezterm = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    programs.wezterm = {
      extraConfig = readFile ./wezterm.lua;
    };
  };
}
