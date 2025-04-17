{
  self,
  pkgs,
  lib,
  ...
}:
let
  inherit (builtins) elem;
  inherit (lib) getName;
in
{
  boot = {
    plymouth.enable = true;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  users.users = {
    luisgois = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "lp"
      ];
      initialPassword = "123456";
      shell = pkgs.zsh;
    };

    dev = {
      isNormalUser = true;
      initialPassword = "123456";
    };
  };

  home-manager.users = {
    luisgois = args: {
      imports = [
        "${self}/homes/luisgois"
      ];
    };
    dev = args: {
      imports = [
        "${self}/homes/dev"
      ];
    };
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
      pkgs.fastfetch
      pkgs.htop
      pkgs.lolcat
      pkgs.tldr
      pkgs.tmux
      pkgs.vim
    ];

    xfce.excludePackages = [
      # NOTE: Needed to not conflict with dunst dbus activation because they
      # both have the same bus name
      pkgs.xfce.xfce4-notifyd
      pkgs.xfce.xfce4-volumed-pulse
    ];

  };

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    [
      "stremio-server"
      "stremio-shell"
    ]
    |> elem (getName pkg);

  programs = {
    htop.enable = true;
    hyprland.enable = true;
    less.enable = true;
    nh.enable = true;
    tmux.enable = true;
    yazi.enable = true;
    zsh.enable = true;
  };

  services = {
    automatic-timezoned.enable = true;
    displayManager.sddm.enable = true;
    flatpak.enable = true;
    guix.enable = true;
    locate.enable = true;
    thermald.enable = true;
    upower.enable = true;
    xserver.enable = true;
  };

  services.xserver.desktopManager = {
    xfce.enable = true;
  };

  networking = {
    networkmanager.enable = true;
  };

  powerManagement.enable = true;

  stylix.enable = true;

  system.stateVersion = "25.05";
}
