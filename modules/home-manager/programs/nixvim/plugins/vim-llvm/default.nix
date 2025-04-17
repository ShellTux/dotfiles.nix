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

  cfg = config.programs.nixvim.plugins.vim-llvm;
in
{
  options.programs.nixvim.plugins.vim-llvm = {
    enable = mkEnableOption "Enable vim-llvm plugin";

    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };

    package = mkPackageOption pkgs.vimPlugins "vim-llvm" { };
  };

  config = {
    programs.nixvim = {
      extraPlugins = mkIf (cfg.enable && !cfg.disableModule) [
        cfg.package
      ];
    };
  };
}
