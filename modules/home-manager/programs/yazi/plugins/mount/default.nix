{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.programs.yazi;
in
{
  programs.yazi = mkIf cfg.enable {
    plugins = { inherit (pkgs.yaziPlugins) mount; };

    keymap.mgr.prepend_keymap = [
      {
        on = "M";
        run = "plugin mount";
      }
    ];
  };
}
