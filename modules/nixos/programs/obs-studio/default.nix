{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool;

  cfg = config.programs.obs-studio;
in
{
  options.programs.obs-studio = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    programs.obs-studio = mkDefault {
      enableVirtualCamera = true;
      plugins =
        let
          plugin = pkgs.obs-studio-plugins;
        in
        [
          # plugin.advanced-scene-switcher
          plugin.droidcam-obs
          plugin.input-overlay
          # plugin.obs-advanced-masks
          plugin.obs-backgroundremoval
          # plugin.obs-browser-transition
          # plugin.obs-color-monitor
          # plugin.obs-command-source
          # plugin.obs-composite-blur
          # plugin.obs-dir-watch-media
          # plugin.obs-dvd-screensaver
          # plugin.obs-freeze-filter
          # plugin.obs-gstreamer
          # plugin.obs-livesplit-one
          # plugin.obs-markdown
          # plugin.obs-media-controls
          # plugin.obs-multi-rtmp
          # plugin.obs-mute-filter
          plugin.obs-noise
          plugin.obs-pipewire-audio-capture
          # plugin.obs-recursion-effect
          # plugin.obs-retro-effects
          # plugin.obs-rgb-levels
          # plugin.obs-scene-as-transition
          # plugin.obs-source-record
          # plugin.obs-teleport
          # plugin.obs-transition-table
          # plugin.obs-urlsource
          plugin.obs-vaapi
          # plugin.obs-vertical-canvas
          plugin.obs-vkcapture
          # plugin.obs-vnc
          plugin.waveform
          plugin.wlrobs
        ];
    };
  };
}
