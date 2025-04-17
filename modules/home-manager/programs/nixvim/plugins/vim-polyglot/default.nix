{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    mkPackageOption
    ;
  inherit (lib.types) bool;

  cfg = config.programs.nixvim.plugins.vim-polyglot;
in
{
  options.programs.nixvim.plugins.vim-polyglot = {
    enable = mkEnableOption "Wether to enable vim-polyglot";

    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };

    package = mkPackageOption pkgs.vimPlugins "vim-polyglot" { };
  };

  config.programs.nixvim.extraPlugins = mkIf cfg.enable [ cfg.package ];
}
