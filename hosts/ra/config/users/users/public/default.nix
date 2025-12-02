{ config, ... }:
let
  username = "public";
in
{
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [
      "ssh-users"
    ];
    initialPassword = "123456";
    homeMode = "750";
  };

  services.immich = {
    externalLibraries = [ "/home/${username}/Imagens" ];
    extraGroups = [ "users" ];
  };

  home-manager.users.${username} =
    { pkgs, ... }:
    {
      programs = {
        bash.enable = true;
        btop.enable = true;
        eza.enable = true;
        fastfetch.enable = true;
        fd.enable = true;
        fzf.enable = true;
        htop.enable = true;
        nh.enable = true;
        tealdeer.enable = true;
        vim.enable = true;
        yt-dlp.enable = true;
      };

      xdg.userDirs = {
        enable = true;
        createDirectories = true;
      };

      home.stateVersion = "25.11";
    };

}
