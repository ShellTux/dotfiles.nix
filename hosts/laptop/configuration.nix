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
  imports = [
    ./config
  ];

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
        "libvirtd"
        "lp"
        "wheel"
      ];
      initialPassword = "123456";
      shell = pkgs.zsh;
    };

    dev = {
      isNormalUser = true;
      initialPassword = "123456";
    };

    streamer = {
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

    streamer = args: {
      imports = [
        "${self}/homes/streamer"
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
      pkgs.sshfs
      pkgs.tldr
      pkgs.tmux
      pkgs.vim
    ];

    xfce.excludePackages = [
      # NOTE: Needed to not conflict with dunst dbus activation because they
      # both have the same bus name
      pkgs.xfce4-notifyd
      pkgs.xfce4-volumed-pulse
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
    dwl.enable = true;
    htop.enable = true;
    hyprland.enable = true;
    less.enable = true;
    nh.enable = true;
    obs-studio.enable = true;
    tmux.enable = true;
    virt-manager.enable = true;
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
    stevenblack.enable = true;
  };

  powerManagement.enable = true;

  stylix.enable = true;

  virtualisation.libvirtd.enable = true;

  system.stateVersion = "25.05";
}
