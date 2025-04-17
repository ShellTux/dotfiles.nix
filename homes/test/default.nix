{ ... }:
{
  home = rec {
    username = "test";
    homeDirectory = "/home/${username}";
    stateVersion = "25.05";
  };

  wayland.windowManager.hyprland.enable = true;

  programs.home-manager.enable = true;
}
