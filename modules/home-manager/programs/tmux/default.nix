{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool;

  cfg = config.programs.tmux;
in
{
  imports = [
    ./plugins
    ./extraConfig
  ];

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
      escapeTime = 100;
      historyLimit = 10000;
      keyMode = "vi";
      mouse = true;
      prefix = "C-space";
      sensibleOnTop = true;
      terminal = "screen-256color";
    };
  };
}
