{ ... }:
{
  home = rec {
    username = "USERNAME";
    homeDirectory = "/home/${username}";
    stateVersion = null;
  };

  programs.home-manager.enable = true;
}
