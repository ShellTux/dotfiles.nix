{ config, lib, ... }:
let
  inherit (builtins) mapAttrs;
  inherit (lib) mkIf mkDefault;

  cfg = config.flake.wrappers.eza;
in
mkIf cfg.enable {
  home = {
    packages = [ cfg.package ];

    shellAliases = mapAttrs (_name: value: mkDefault value) {
      ls = "eza";
      ll = "eza --long";
      la = "eza --all";
      lA = "eza --almost-all";
      lt = "eza --tree";
      lla = "eza --long --all";
      llA = "eza --long --almost-all";
      tree = "eza --tree";
    };
  };
}
