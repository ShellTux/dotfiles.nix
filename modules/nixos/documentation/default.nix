{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool;

  cfg = config.documentation;
in
{
  options.documentation = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    documentation = mkDefault {
      dev.enable = true;
      doc.enable = true;
      info.enable = true;
      man = {
        enable = true;
        generateCaches = true;
        man-db.enable = true;
      };
      nixos = {
        enable = true;
        # includeAllModules = true;
        extraModules = [
          inputs.self.nixosModules.default
        ];
      };
    };

    environment.systemPackages = [
      pkgs.man
      pkgs.man-db
      pkgs.man-pages
      pkgs.man-pages-posix
    ];
  };
}
