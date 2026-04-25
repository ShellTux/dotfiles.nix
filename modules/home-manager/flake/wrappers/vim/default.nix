{ config, lib, ... }:
let
  inherit (lib) mkIf mkOption getExe;
  inherit (lib.types) bool;

  cfg = config.flake.wrappers.vim;
in
{
  options.flake.wrappers.vim.defaultEditor = mkOption {
    type = bool;
    description = "Whether to enable vim as the default editor.";
    default = false;
    example = true;
  };

  config.home = mkIf cfg.enable {
    packages = [ cfg.package ];

    sessionVariables.EDITOR = mkIf cfg.defaultEditor (getExe cfg.package);
  };
}
