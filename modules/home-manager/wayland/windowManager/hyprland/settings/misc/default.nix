{ ... }:
{
  wayland.windowManager.hyprland.settings.misc = {
    enable_swallow = true;
    swallow_regex = "^(Alacritty|kitty|St)$";
    # HACK: swallow_exception_regex only works assuming parent window to be
    # swallowed changed to the title of swallower window
    # This can be achieved by defining a function in your shell `preexec` (zsh
    # only).
    # You can look up preexec for bash: https://github.com/rcaloras/bash-preexec
    swallow_exception_regex = "^(wev|ueberzugpp_.*|ranger)$";
    mouse_move_enables_dpms = true;
    key_press_enables_dpms = true;
  };
}
