{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  inherit (lib.types) bool;

  cfg = config.programs.ffmpeg;
in
{
  options.programs.ffmpeg = {
    enable = mkEnableOption "Wether to enable ffmpeg";

    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };

    package = mkOption {
      type = types.package;
      default = pkgs.ffmpeg;
      example = pkgs.ffmpeg-full;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    programs.ffmpeg = { };

    home = {
      packages = [ cfg.package ];
      shellAliases.ffmpeg-stat = "ffmpeg -loglevel warning -stats";
    };
  };
}
