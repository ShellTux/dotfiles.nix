{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption mkIf;
  inherit (lib.types) bool;

  cfg = config.programs.neovide;
in
{
  options.programs.neovide = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    programs.neovide.settings.font.normal = [ "JetBrainsMono Nerd Font" ];
    home.packages = [ pkgs.nerd-fonts.jetbrains-mono ];
  };
}
