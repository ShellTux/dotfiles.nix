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
    programs.zsh.cdpath = mkDefault [
      "~"
      "~/.local/src"
      "~/.local/bin"
      "~/.local"
      "/etc"
    ];
  };
}
