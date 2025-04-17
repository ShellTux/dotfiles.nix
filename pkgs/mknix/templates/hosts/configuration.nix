{ pkgs, ... }:
{
  users.users.user = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    initialPassword = "123456";
  };

  environment = {
    variables = {
      TERM = "screen-256color";
    };

    systemPackages = [
      pkgs.bat
      pkgs.btop
      pkgs.cowsay
      pkgs.curl
      pkgs.htop
      pkgs.lolcat
      pkgs.tldr
      pkgs.tmux
      pkgs.vim
    ];
  };

  system.stateVersion = "25.05";
}
