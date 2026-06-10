{
  config,
  lib,
  lib',
  ...
}:
let
  inherit (lib) mkIf genAttrs;
  inherit (lib'.flake.hyprland.lua) mkWindowRuleOpaque mkWindowRuleIdleInhibit;

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

  wayland.windowManager.hyprland.settings.window_rule =
    map (mkWindowRuleIdleInhibit "focus") [
      { match.class = "mpv"; }
    ]
    ++ map mkWindowRuleOpaque [
      { match.class = "mpv"; }
    ];
}
