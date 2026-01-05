{ ... }:
{
  warnings = [
    "ISSUE(mpv): https://github.com/mpv-player/mpv/issues/17204"
    "ISSUE(mpv): https://github.com/hyprwm/Hyprland/discussions/12829"
  ];

  programs.mpv.config.target-colorspace-hint-mode = "source";
}
