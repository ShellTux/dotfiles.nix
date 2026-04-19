{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (builtins) readFile fromJSON;
  inherit (lib) mkIf pipe;
in
mkIf (config.flavour == "config1") {
  settings = pipe ./noctalia.json [
    readFile
    fromJSON
  ];

  extraPackages = [
    pkgs.curl
    pkgs.ffmpeg
    pkgs.gifski
    pkgs.grim
    pkgs.imagemagick
    pkgs.kitty
    pkgs.noctalia-shell
    pkgs.quickshell
    pkgs.slurp
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
    pkgs.zbar
  ];
}
