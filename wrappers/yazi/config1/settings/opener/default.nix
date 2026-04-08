{
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf;
in
mkIf (config.flavour == "config1") {
  extraPackages = [
    pkgs.exiftool
    pkgs.imv
    pkgs.mpv
    pkgs.unar
  ];

  settings.yazi.opener = rec {
    play = [
      {
        run = ''mpv "$@"'';
        block = false;
        for = "unix";
        desc = " Mpv";
      }
    ];
    video = play;
    audio = play;

    edit = [
      {
        run = ''$EDITOR "$@"'';
        block = true;
        for = "unix";
      }
      {
        run = ''nvim "$@"'';
        block = true;
        for = "unix";
        desc = " Neovim";
      }
      {
        run = ''vim "$@"'';
        block = true;
        for = "unix";
        desc = " Vim";
      }
      {
        run = ''nano "$@"'';
        block = true;
        for = "unix";
        desc = " Nano";
      }
    ];

    open = [
      {
        run = ''xdg-open "$@"'';
        desc = "Open";
      }
    ]
    ++ play;

    image = [
      {
        run = ''imv "$@"'';
        block = false;
        for = "linux";
        desc = "Imv";
      }
    ]
    ++ play;

    extract = [
      {
        run = ''unar "$1"'';
        desc = " Unar: Extract here";
        for = "unix";
      }
    ];
  };
}
