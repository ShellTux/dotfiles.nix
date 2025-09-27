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
    mkOption
    ;
  inherit (lib.types) str;

  fastfetch = getExe pkgs.fastfetch;

  cfg = config.programs.zsh;
in
{
  options.programs.zsh.init = {
    extraFirst = mkOption {
      description = "Early initialization";
      type = str;
      default = "";
    };

    extraBeforeCompInit = mkOption {
      description = "Before completion initialization";
      type = str;
      default = "";
    };

    extra = mkOption {
      description = "General configuration";
      type = str;
      default = "";
    };

    afterExtra = mkOption {
      description = "General configuration";
      type = str;
      default = ''
        ${fastfetch}
      '';
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    programs.zsh.initContent =
      let
        initExtraFirst = mkBefore cfg.init.extraFirst;
        initExtraBeforeCompInit = mkOrder 550 cfg.init.extraBeforeCompInit;
        initExtra = mkOrder 1000 cfg.init.extra;
        initAfterExtra = mkAfter cfg.init.afterExtra;
      in
      mkMerge [
        initExtraFirst
        initExtraBeforeCompInit
        initExtra
        initAfterExtra
      ];
  };
}
