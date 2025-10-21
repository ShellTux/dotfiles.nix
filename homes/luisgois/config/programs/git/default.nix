{ ... }:
{
  imports = [
    ./includes.crypt.nix
  ];

  programs.git.settings.user = {
    name = "ShellTux";
    email = "115948079+ShellTux@users.noreply.github.com";
  };
}
