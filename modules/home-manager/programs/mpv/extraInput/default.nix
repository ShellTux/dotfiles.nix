{ config, lib, ... }:
let
  inherit (lib) mkIf;

  cfg = config.programs.mpv;
in
{
  config = mkIf (cfg.enable && !cfg.disableModule) {
    programs.mpv.extraInput = ''
      CTRL+SHIFT+p script-binding console/enable
      F1 script-binding console/enable
      CTRL+SHIFT+r cycle_values video-rotate 90 180 270 0
      Ctrl+Alt+RIGHT cycle video-rotate 90
      Ctrl+Alt+LEFT cycle video-rotate -90
    '';
  };
}
