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
    mkMerge
    getExe
    ;
  inherit (lib.types) bool;

  cfg = config.programs.bash;

  fastfetch = getExe pkgs.fastfetch;
in
{
  options.programs.bash = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    programs.bash = mkDefault {
      enableCompletion = true;
      historyControl = [
        # "erasedups"
        "ignoredups"
        "ignorespace"
      ];
      historyFileSize = 100000;
      historyIgnore = [
        "[bf]g"
        "cd"
        "clear"
        "exit"
        "ls"
        "shred"
        "[ t\]*"
      ];
      sessionVariables = {
        CDPATH = ''.:$HOME:${config.xdg.configHome}:$HOME/.local/src:$HOME/.local:/etc'';
        PS1 = ''┌──\[\e[0m\]\[\e[1m\][ \[\e[0;1;38;5;48m\]\u\[\e[0;1;1;38;5;226m\]@\[\e[0;1;38;5;196m\]\h\[\e[0;1m\] \`if [ \$(stat --format %u .) = 0 ]; then printf 🔐; fi\` \w ]\[\e[0m\]\[\e[0;3;96m\]\$(git branch --show-current 2>/dev/null | sed 's/^/ (/;s/$/)/;') \[\e[0m\]( \`if [ \$? = 0 ]; then printf '\[\e[0;1;38;5;48m\]✓'; else printf '\[\e[0;1;38;5;196m\]✕'; fi\`\[\e[0m\] )\n└──   \[\e[0;1;38;5;50m\]$ \[\e[0m\]'';
      };
      shellOptions = [
        "histappend"
        "checkwinsize"
        "extglob"
        "globstar"
        "checkjobs"
        "autocd"
      ];
      initExtra = mkMerge [ fastfetch ];
    };
  };
}
