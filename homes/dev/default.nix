{ ... }:
{
  home = rec {
    username = "dev";
    homeDirectory = "/home/${username}";
    stateVersion = "25.05";
  };

  programs = {
    bat.enable = true;
    btop.enable = true;
    direnv.enable = true;
    eza.enable = true;
    fastfetch.enable = true;
    fd.enable = true;
    fzf.enable = true;
    git.enable = true;
    htop.enable = true;
    nixvim.enable = true;
    nix-your-shell.enable = true;
    tealdeer.enable = true;
    vim.enable = true;
  };

  programs.home-manager.enable = true;
}
