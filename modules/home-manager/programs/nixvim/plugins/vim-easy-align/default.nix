{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkIf
    mkOption
    mkEnableOption
    mkPackageOption
    ;
  inherit (lib.types) bool;

  cfg = config.programs.nixvim.plugins.vim-easy-align;
in
{
  options.programs.nixvim.plugins.vim-easy-align = {
    enable = mkEnableOption "Enable vim-easy-align plugin";

    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };

    package = mkPackageOption pkgs.vimPlugins "vim-easy-align" { };
  };

  config = {
    programs.nixvim = {
      keymaps = mkIf (cfg.enable && !cfg.disableModule) [
        {
          mode = [ "x" ];
          key = "ga";
          action = "<Plug>(EasyAlign)";
          options.desc = "EasyAlign";
        }
      ];

      extraPlugins = mkIf (cfg.enable && !cfg.disableModule) [
        cfg.package
      ];
    };
  };
}
