{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (builtins) readFile;
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool;

  cfg = config.programs.vim;
in
{
  options.programs.vim = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    programs.vim = {
      settings = mkDefault {
        background = "dark";
        expandtab = true;
        ignorecase = true;
        number = true;
        relativenumber = false;
        shiftwidth = 4;
        smartcase = true;
        tabstop = 4;
      };

      extraConfig = readFile ./extra-config.vim;

      plugins = [
        pkgs.vimPlugins.auto-pairs
        pkgs.vimPlugins.vim-airline
      ];
    };
  };
}
