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
    programs.zsh.history =
      let
        inherit (config.xdg) dataHome;

        size = 999999;
        save = size;
        path = "${dataHome}/zsh/zsh_history";
      in
      mkDefault {
        inherit size save path;

        expireDuplicatesFirst = true;
        ignoreAllDups = true;
        # TODO: share with bash
        ignorePatterns = [
          "[bf]g"
          "cd"
          "clear"
          "exit"
          "ls *"
          "shred *"
          "pkill *"
        ];
      };
  };
}
