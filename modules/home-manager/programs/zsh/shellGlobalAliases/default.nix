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
    programs.zsh.shellGlobalAliases = mkDefault {
      G = "| grep";
      help = "--help 2>&1 | bat --language=help --style=plain";
      UUID = "$(uuidgen | tr -d \\n)";
    };
  };
}
