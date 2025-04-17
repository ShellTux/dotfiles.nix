{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.programs.tmux;
in
{
  config = mkIf (cfg.enable && !cfg.disableModule) {
    programs.tmux.plugins =
      let
        inherit (pkgs) tmuxPlugins;
      in
      [
        tmuxPlugins.catppuccin
        tmuxPlugins.vim-tmux-navigator
      ];
  };
}
