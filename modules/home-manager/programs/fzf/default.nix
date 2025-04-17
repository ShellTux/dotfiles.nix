{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkOption
    mkIf
    mkDefault
    getExe
    ;
  inherit (lib.types) bool;

  bat = getExe pkgs.bat;

  cfg = config.programs.fzf;
in
{
  options.programs.fzf = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) (mkDefault {
    programs.fzf = {
      enableZshIntegration = true;
    };

    home.shellAliases = {
      fzf = ''fzf --preview "${bat} --color=always --style=numbers --line-range=:500 {}"'';
    };
  });
}
