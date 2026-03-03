{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.programs.zsh;
in
{
  config = mkIf (cfg.enable && !cfg.disableModule) {
    programs.zsh.localVariables = {
      PS1 = "%F{green}%n%f%F{yellow}@%f%F{red}%m%f %F{cyan}%~%f $ ";
    };
  };
}
