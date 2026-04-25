{
  config,
  self',
  pkgs,
  lib,
  dev-tools,
  ...
}:
let
  inherit (lib) getExe;
in
{
  imports = [
    ./config
  ];

  home = {
    username = "luisgois";

    packages = [
      pkgs.android-file-transfer
      pkgs.ani-cli
      pkgs.anki
      pkgs.autenticacao-gov-pt-bin
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
      pkgs.libreoffice
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
      pkgs.sl
      pkgs.speedtest-cli
      pkgs.supersonic
      pkgs.tealdeer
      pkgs.unar
      pkgs.vimv
      pkgs.virt-viewer
      pkgs.wl-clipboard
      pkgs.xdg-ninja
    ]
    ++ [
      dev-tools.nixvim
    ]
    ++ [
      self'.packages.brightness
      self'.packages.help
      self'.packages.ipa
      self'.packages.mktouch
      self'.packages.mounts
      # self'.packages.mpd-notification
      self'.packages.nix-out-paths
      self'.packages.notify-music
      self'.packages.open
      self'.packages.repl
      self'.packages.swap
      self'.packages.umounts
      self'.packages.vman
      self'.packages.volume
      self'.packages.walld
      self'.packages.wclip
    ];

    sessionVariables = {
      EDITOR = getExe config.flake.wrappers.vim.package;
    };
  };

  flake.wrappers = {
    bat.enable = true;
    btop.enable = true;
    eza.enable = true;
    fastfetch.enable = true;
    fd.enable = true;
    htop.enable = true;
    kitty.enable = true;
    mpv.enable = true;
    vim.enable = true;
    yazi.enable = true;
    yt-dlp.enable = true;
  };

  programs = {
    bash.enable = true;
    brave.enable = true;
    diff-so-fancy.enable = true;
    direnv.enable = true;
    emacs.enable = true;
    floorp.enable = true;
    fzf.enable = true;
    gemini-cli.enable = true;
    ghostty.enable = true;
    jellyfin.enable = true;
    jq.enable = true;
    ncmpcpp.enable = true;
    newsboat.enable = true;
    nh.enable = true;
    nix-index-database.comma.enable = true;
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
    wezterm.enable = true;
    xournalpp.enable = true;
    zathura.enable = true;
    zsh.enable = true;
  };

  services = {
    dunst.enable = true;
    easyeffects.enable = true;
    emacs.enable = true;
    gammastep.enable = true;
    jellyfin-mpv-shim.enable = true;
    mpd.enable = true;
    mpd-mpris.enable = true;
    mpd-notification.enable = true;
    poweralertd.enable = true;
    ssh-agent.enable = true;
  };

  xdg.enable = true;

  stylix.enable = true;

  wayland.windowManager = {
    hyprland = {
      enable = true;
      pyprland.enable = true;
      bar.noctalia-shell = self'.packages.noctalia-shell;
    };
  };

  sops.defaultSopsFile = ./secrets.yaml;

  programs.home-manager.enable = true;
}
