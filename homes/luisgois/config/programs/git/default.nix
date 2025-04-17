{ ... }:
{
  imports = [
    ./includes.crypt.nix
  ];

  programs.git = {
    userName = "ShellTux";
    userEmail = "115948079+ShellTux@users.noreply.github.com";
  };
}
