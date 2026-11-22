{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf genAttrs;

  cfg = config.flake.wrappers.mpv;
in
mkIf cfg.enable {
  home.packages = [ cfg.package ];

  xdg.mimeApps.defaultApplications = (
    genAttrs [
      "video/mp4"
      "video/webm"
      "video/x-matroska"
      "video/x-msvideo"
    ] (_: "mpv.desktop")
  );
}
