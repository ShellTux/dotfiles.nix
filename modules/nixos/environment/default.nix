{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool;

  cfg = config.environment;
in
{
  options.environment = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (!cfg.disableModule) {
    environment = mkDefault {
      variables = {
        TERM = "screen-256color";
      };

      systemPackages = [
        pkgs.bat
        pkgs.btop
        pkgs.curl
        pkgs.htop
        pkgs.tldr
        pkgs.tmux
        pkgs.vim
      ];
    };
  };
}
