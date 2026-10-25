{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (builtins) readFile fromTOML;
  inherit (lib) mkIf pipe;
in
mkIf (config.flavour == "config1") {
  settings = pipe ./noctalia.toml [
    readFile
    fromTOML
  ];

  runtimePkgs = [
    pkgs.curl
    pkgs.ffmpeg
    pkgs.fzf
    pkgs.gifski
    pkgs.gpu-screen-recorder
    pkgs.grim
    pkgs.imagemagick
    pkgs.kitty
    pkgs.localsend
    pkgs.mpv
    pkgs.mpvpaper
    pkgs.nix-search-tv
    pkgs.openssl
    pkgs.python3
    pkgs.qrencode
    pkgs.quickshell
    pkgs.slurp
    pkgs.socat
    (pkgs.tesseract.override {
      enableLanguages = [
        "ara"
        "chi_sim"
        "chi_sim_vert"
        "chi_tra"
        "chi_tra_vert"
        "deu"
        "eng"
        "fra"
        "ita"
        "ita_old"
        "jpn"
        "jpn_vert"
        "kan"
        "kat"
        "kat_old"
        "kor"
        "kor_vert"
        "lat"
        "oci"
        "ori"
        "osd"
        "por"
        "rus"
        "tha"
      ];
    })
    pkgs.translate-shell
    pkgs.wf-recorder
    pkgs.wl-clipboard
    pkgs.xdg-desktop-portal
    pkgs.xdg-utils
    pkgs.zbar
  ];
}
