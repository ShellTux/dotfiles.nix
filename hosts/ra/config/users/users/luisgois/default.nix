{ config, ... }:
let
  inherit (config.networking) localFqdn;

  username = "luisgois";
in
{
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "ssh-users" ];
    hashedPassword = "!";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJK+iESNidBhZORlp8E/uLm0pNh2m3UKHbSa1NY7CNYW luisgois@${localFqdn}"
    ];
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
