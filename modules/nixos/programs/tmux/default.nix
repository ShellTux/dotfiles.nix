{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool;

  cfg = config.programs.tmux;
in
{
  options.programs.tmux = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    programs.tmux = mkDefault {
      baseIndex = 1;
      clock24 = true;
      keyMode = "vi";
      shortcut = "space";
      terminal = "screen-256color";

      plugins =
        let
          inherit (pkgs) tmuxPlugins;
        in
        [
          tmuxPlugins.sensible
          tmuxPlugins.tokyo-night-tmux
          tmuxPlugins.vim-tmux-navigator
        ];
    };
  };
}
