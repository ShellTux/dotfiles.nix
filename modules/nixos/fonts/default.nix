{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool;

  cfg = config.fonts;
in
{
  options.fonts = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (!cfg.disableModule) {
    fonts = {
      packages = [
        pkgs.font-awesome
        pkgs.jetbrains-mono
        pkgs.noto-fonts-cjk-sans

        pkgs.nerd-fonts.symbols-only
      ];
    };
  };
}
