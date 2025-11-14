{ pkgs, flake-pkgs, ... }:
{
  imports = [
    ./config
  ];

  home = rec {
    username = "streamer";
    homeDirectory = "/home/${username}";
    stateVersion = "25.05";

    packages = [
      pkgs.droidcam
      pkgs.gimp3-with-plugins
    ]
    ++ [
      flake-pkgs.nixvim
    ];
  };

  programs = {
    bash.enable = true;
    bat.enable = true;
    btop.enable = true;
    direnv.enable = true;
    eza.enable = true;
    fastfetch.enable = true;
    fd.enable = true;
    floorp.enable = true;
    fzf.enable = true;
    git.enable = true;
    htop.enable = true;
    mpv.enable = true;
    nh.enable = true;
    nix-your-shell.enable = true;
    obs-studio.enable = true;
    ssh.enable = true;
    tealdeer.enable = true;
    tmux.enable = true;
    vim.enable = true;
    waybar.enable = true;
    wezterm.enable = true;
    wofi.enable = true;
    zathura.enable = true;
  };

  services = {
    dunst.enable = true;
    easyeffects.enable = true;
    gammastep.enable = true;
    # hyprshell.enable = true;
    mpd.enable = true;
    mpd-mpris.enable = true;
    mpd-notification.enable = true;
    poweralertd.enable = true;
    ssh-agent.enable = true;
    wpaperd.enable = true;
  };

  wayland.windowManager = {
    hyprland.enable = true;
  };

  stylix.enable = true;
  xdg.enable = true;

  sops.defaultSopsFile = ./secrets.yaml;

  programs.home-manager.enable = true;
}
