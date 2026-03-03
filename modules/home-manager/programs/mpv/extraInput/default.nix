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
    '';
  };
}
