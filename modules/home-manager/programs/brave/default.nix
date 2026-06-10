{
  config,
  lib,
  lib',
  pkgs,
  ...
}:
let
  inherit (lib) mkOption mkIf;
  inherit (lib.types) bool;
  inherit (lib'.flake.hyprland.lua)
    mkWindowRuleIdleInhibit
    mkWindowRuleFloat
    mkWindowRuleSize
    ;

  cfg = config.programs.brave;
in
{
  options.programs.brave = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = {
    programs.brave = mkIf (cfg.enable && !cfg.disableModule) {
      commandLineArgs = [
        "--ozone-platform-hint=auto"
      ];

      extensions = [
        pkgs.brave.extensions.augmented-steam
        pkgs.brave.extensions.bitwarden
        pkgs.brave.extensions.dark-reader
        pkgs.brave.extensions.DeArrow
        pkgs.brave.extensions.enhancer-for-youtube
        pkgs.brave.extensions.ff2mpv
        pkgs.brave.extensions.material-icons-for-github
        pkgs.brave.extensions.protondb-for-steam
        pkgs.brave.extensions.return-youtube-dislike
        pkgs.brave.extensions.search-by-image
        pkgs.brave.extensions.sponsorblock-for-youtube
        pkgs.brave.extensions.ublock-origin
        pkgs.brave.extensions.vimium
        pkgs.brave.extensions.xbrowsersync
        pkgs.brave.extensions.zotero-connector
      ];
    };

    wayland.windowManager.hyprland.settings.window_rule =
      map (mkWindowRuleIdleInhibit "focus") [
        { match = "title (.*)(YouTube)(.*)"; }
      ]
      ++ map (mkWindowRuleIdleInhibit "fullscreen") [
        { match = "class ^(brave)$"; }
      ]
      ++ map mkWindowRuleFloat [
        { match.initial_title = "^(Save File)$"; }
        { match.initial_title = "(.*)(wants to save)$"; }
      ]
      ++
        map
          (mkWindowRuleSize [
            "<50%"
            "<50%"
          ])
          [
            { match.initial_title = "^(Save File)$"; }
            { match.initial_title = "(.*)(wants to save)$"; }
          ];
  };
}
