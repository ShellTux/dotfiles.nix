{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf mkMerge;

  cfg = config.programs.zsh;
  zstyle = text: "zstyle ':completion:*' ${text}";
in
{
  config = mkIf (cfg.enable && !cfg.disableModule) {
    programs.zsh.completionInit = mkMerge [
      (zstyle "menu select")
      (zstyle "completer _expand _complete _ignored _correct _approximate")
      (zstyle "glob 'NUMERIC == 2'")
      (zstyle "matcher-list '+m:{[:lower:]}={[:upper:]} m:{[:lower:][:upper:]}={[:upper:][:lower:]} r:|[._-]=* r:|=*'")
      (zstyle "max-errors 3 not-numeric")
      (zstyle "prompt '%e'")
      "autoload -U compinit && compinit"
    ];
  };
}
