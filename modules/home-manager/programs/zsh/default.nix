{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    mkOption
    mkIf
    mkDefault
    ;
  inherit (lib.types) bool;

  cfg = config.programs.zsh;
in
{
  imports = [
    ./cdpath
    ./completionInit
    ./history
    ./initContent
    ./localVariables
    ./shellGlobalAliases
    ./syntaxHighlighting
  ];

  options.programs.zsh = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    programs.zsh = mkDefault {
      autocd = true;
      autosuggestion.enable = true;
      defaultKeymap = "emacs";
      dirHashes.docs = "$HOME/Documentos";
      dotDir = "${config.xdg.configHome}/zsh";
      enableCompletion = true;
    };
  };
}
