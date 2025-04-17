{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf mkDefault;

  cfg = config.programs.zsh;
in
{
  config = mkIf (cfg.enable && !cfg.disableModule) {
    programs.zsh.syntaxHighlighting = mkDefault {
      enable = true;
      highlighters = [
        "main"
        "brackets"
        "pattern"
        "regexp"
      ];
      patterns = {
        "rm -rf *" = "fg=white,bold,bg=red";
      };
      styles = {
        comment = "fg=black,bold";
      };
    };
  };
}
