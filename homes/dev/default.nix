{ self', ... }:
{
  home = {
    username = "dev";

    packages = [ self'.packages.nixvim ];
  };

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
