{ ... }:
{
  home = rec {
    username = "USERNAME";
    homeDirectory = "/home/${username}";
    stateVersion = "25.05";
  };

  programs.home-manager.enable = true;
}
