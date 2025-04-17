{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool;

  cfg = config.nix;
in
{
  options.nix = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    nix = mkDefault {
      package = pkgs.nix;

      settings = {
        experimental-features = [
          "flakes"
          "nix-command"
        ];
        extra-experimental-features = [ "pipe-operators" ];
      };
      gc = {
        automatic = true;
        options = "--delete-older-than 14d";
      };
    };
  };
}
