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
  inherit (lib'.flake.hyprland.windowrule) idleinhibit float size;

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

    wayland.windowManager.hyprland.settings.windowrule = [
      (idleinhibit {
        match = "title (.*)(YouTube)(.*)";
        idle_inhibit = "focus";
      })
      (idleinhibit {
        match = "class ^(brave)$";
        idle_inhibit = "fullscreen";
      })
      (float { match = "initial_title ^(Save File)$"; })
      (size {
        match = "initial_title ^(Save File)$";
        width = "<50%";
        height = "<50%";
      })
      (float { match = "initial_title (.*)(wants to save)$"; })
      (size {
        match = "initial_title (.*)(wants to save)$";
        width = "<50%";
        height = "<50%";
      })
    ];
  };
}
