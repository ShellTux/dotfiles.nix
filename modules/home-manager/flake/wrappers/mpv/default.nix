{
  config,
  lib,
  lib',
  ...
}:
let
  inherit (lib) mkIf genAttrs;
  inherit (lib'.flake.hyprland.windowrule) opaque idleinhibit;

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

  wayland.windowManager.hyprland.settings.windowrule = [
    (idleinhibit {
      match = "class mpv";
      idle_inhibit = "focus";
    })
    (opaque { match = "class mpv"; })
  ];
}
