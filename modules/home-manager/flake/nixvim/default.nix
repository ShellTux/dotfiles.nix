{
  config,
  lib,
  self',
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    getExe
    ;
  inherit (lib.types) package bool;

  cfg = config.flake.nixvim;
in
{
  options.flake.nixvim = {
    enable = mkEnableOption "nixvim";

    package = mkOption {
      type = package;
      default = self'.packages.nixvim;
      description = "The nixvim package to use.";
    };

    defaultEditor = mkOption {
      type = bool;
      description = "Whether to enable nixvim as the default editor.";
      default = false;
      example = true;
    };
  };

  config = mkIf cfg.enable {
    home = {
      packages = [ cfg.package ];

      sessionVariables.EDITOR = mkIf cfg.defaultEditor (getExe cfg.package);
    };
  };
}
