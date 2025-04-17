{
  lib,
  ...
}:
let
  inherit (lib) mkOption mkDefault genAttrs;
  inherit (lib.types) bool;
in
{
  imports = [
    ./config
    ./profiles
    ./scripts
  ];

  options.programs.mpv = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = {
    xdg.mimeApps.defaultApplications = mkDefault (
      genAttrs [
        "video/mp4"
        "video/webm"
        "video/x-matroska"
        "video/x-msvideo"
      ] (_: "mpv.desktop")
    );

  };
}
