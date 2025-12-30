{
  pkgs,
  flake-pkgs,
  ...
}:
{
  imports = [
    ./config
  ];

  home = rec {
    username = "luisgois";
    homeDirectory = "/home/${username}";
    stateVersion = "25.05";

    packages = [
      pkgs.android-file-transfer
      pkgs.ani-cli
      pkgs.anki
      pkgs.bc
      pkgs.calcurse
      pkgs.dua
      pkgs.easyeffects
      pkgs.ffmpeg
      pkgs.fselect
      pkgs.gimp3-with-plugins
      pkgs.gocryptfs
      pkgs.gtkhash
      pkgs.kdePackages.dolphin
      pkgs.libqalculate
      pkgs.mediainfo
      pkgs.mediainfo-gui
      pkgs.nemo-with-extensions
      pkgs.procs
      pkgs.progress
      pkgs.qbittorrent
      pkgs.qiv
      pkgs.ripgrep
      pkgs.ripgrep-all
      pkgs.rmpc
      pkgs.rsync
      pkgs.silicon
      pkgs.sl
      pkgs.tealdeer
      pkgs.unar
      pkgs.vimv
      pkgs.virt-viewer
      pkgs.webcord
      pkgs.wl-clipboard
      pkgs.xdg-ninja
    ]
    ++ [
      flake-pkgs.brightness
      flake-pkgs.help
      flake-pkgs.ipa
      flake-pkgs.mktouch
      flake-pkgs.mounts
      # flake-pkgs.mpd-notification
      flake-pkgs.nix-out-paths
      flake-pkgs.nixvim
      flake-pkgs.notify-music
      flake-pkgs.open
      flake-pkgs.repl
      flake-pkgs.swap
      flake-pkgs.umounts
      flake-pkgs.vman
      flake-pkgs.volume
      flake-pkgs.walld
      flake-pkgs.wclip
    ];
  };

  programs = {
    bash.enable = true;
    bat.enable = true;
    brave.enable = true;
    btop.enable = true;
    diff-so-fancy.enable = true;
    direnv.enable = true;
    emacs.enable = true;
    eza.enable = true;
    fastfetch.enable = true;
    fd.enable = true;
    floorp.enable = true;
    fzf.enable = true;
    ghostty.enable = true;
    git.enable = true;
    htop.enable = true;
    imv.enable = true;
    jellyfin.enable = true;
    jq.enable = true;
    kitty.enable = true;
    mpv.enable = true;
    ncmpcpp.enable = true;
    newsboat.enable = true;
    nh.enable = true;
    nix-index.enable = true;
    nix-your-shell.enable = true;
    nushell.enable = true;
    oh-my-posh.enable = true;
    rofi.enable = true;
    ssh.enable = true;
    tealdeer.enable = true;
    thunar.enable = true;
    thunderbird.enable = true;
    tmux.enable = true;
    translate-shell.enable = true;
    vim.enable = true;
    waybar.enable = true;
    wezterm.enable = true;
    xournalpp.enable = true;
    yazi.enable = true;
    yt-dlp.enable = true;
    zathura.enable = true;
    zsh.enable = true;
  };

  services = {
    dunst.enable = true;
    easyeffects.enable = true;
    emacs.enable = true;
    gammastep.enable = true;
    hyprshell.enable = true;
    jellyfin-mpv-shim.enable = true;
    mpd.enable = true;
    mpd-mpris.enable = true;
    mpd-notification.enable = true;
    poweralertd.enable = true;
    ssh-agent.enable = true;
    wpaperd.enable = true;
  };

  xdg.enable = true;

  stylix.enable = true;

  wayland.windowManager = {
    hyprland.enable = true;
  };

  xsession.windowManager = {
    awesome.enable = true;
  };

  sops.defaultSopsFile = ./secrets.yaml;

  programs.home-manager.enable = true;
}
