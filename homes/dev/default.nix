{ ... }:
{
  home = {
    username = "dev";

    packages = [ ];
  };

  flake.nixvim.enable = true;

  programs = {
    bash.enable = true;
    bat.enable = true;
    btop.enable = true;
    direnv.enable = true;
    eza.enable = true;
    fastfetch.enable = true;
    fd.enable = true;
    fzf.enable = true;
    git.enable = true;
    htop.enable = true;
    nh.enable = true;
    nix-your-shell.enable = true;
    tealdeer.enable = true;
    vim.enable = true;
  };

  programs.home-manager.enable = true;
}
