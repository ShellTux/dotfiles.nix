{ config, lib, ... }:
let
  inherit (lib) mkIf;

  cfg = config.flake.wrappers.eza;
in
mkIf cfg.enable {
  home = {
    packages = [ cfg.package ];

    shellAliases = {
      tree = "eza --color=auto --color-scale all --icons --tree --git-ignore";
    };
  };
}
