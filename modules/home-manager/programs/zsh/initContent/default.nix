{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkIf
    getExe
    mkBefore
    mkOrder
    mkAfter
    mkMerge
    ;

  fastfetch = getExe pkgs.fastfetch;

  cfg = config.programs.zsh;
in
{
  config = mkIf (cfg.enable && !cfg.disableModule) {
    programs.zsh.initContent =
      let
        initExtraFirst = mkBefore "";
        initExtraBeforeCompInit = mkOrder 550 "";
        initExtra = mkOrder 1000 "";
        initAfterExtra = mkAfter ''
          ${fastfetch}
        '';
      in
      mkMerge [
        initExtraFirst
        initExtraBeforeCompInit
        initExtra
        initAfterExtra
      ];
  };
}
