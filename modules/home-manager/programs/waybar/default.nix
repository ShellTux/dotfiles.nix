{
  config,
  lib,
  ...
}:
let
  inherit (builtins) readFile;
  inherit (lib) mkOption mkIf mkAfter;
  inherit (lib.types) bool;

  cfg = config.programs.waybar;
in
{
  options.programs.waybar = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  imports = [
    ./settings
  ];

  config = mkIf (cfg.enable && !cfg.disableModule) {
    programs.waybar = {
      style = mkAfter (readFile ./style.css);
    };
  };
}
