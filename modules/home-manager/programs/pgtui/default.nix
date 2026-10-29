{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (builtins) map concatStringsSep;
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    pipe
    types
    ;

  dbs = pipe cfg.dbs [
    (map (db: " \"${db}\","))
    (concatStringsSep "\n")
  ];

  cfg = config.programs.pgtui;
in
{
  options.programs.pgtui = {
    enable = mkEnableOption "Whether to enable this program";

    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = types.bool;
      default = false;
    };

    package = mkOption {
      description = "Which package of pgtui to use.";
      type = types.package;
      default = pkgs.pgtui;
    };

    dbs = mkOption {
      description = "Dbs";
      type = types.listOf types.str;
      default = [ ];
      example = [ "postgresql://user:password@localhost:5432/db" ];
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    home.packages = [ cfg.package ];

    xdg.configFile."pgtui/config.toml".text = ''
      dbs = [
        ${dbs}
      ]
    '';
  };
}
