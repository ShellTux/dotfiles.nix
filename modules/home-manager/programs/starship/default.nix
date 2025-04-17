{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool;

  cfg = config.programs.starship;
in
{
  options.programs.starship = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    programs.starship = mkDefault {
      enableBashIntegration = true;
      enableTransience = true;
      settings = {
        add_newline = true;
        scan_timeout = 10;
        character.success_symbol = "[➜](bold green)";
        package.disabled = false;
      };
    };
  };
}
