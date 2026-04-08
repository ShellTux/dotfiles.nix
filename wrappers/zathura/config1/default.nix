{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
in
mkIf (config.flavour == "config1") {
  settings = {
    guioptions = "sv";
    adjust-open = "width";
    recolor = true;
    selection-clipboard = "clipboard";
    window-title-basename = true;
    incremental-search = true;
  };

  mappings = {
    j = "navigate next";
    k = "navigate previous";
    "<S-j>" = "scroll down 10";
    "<S-k>" = "scroll up 10";
    h = "scroll down 10";
    l = "scroll up 10";
  };

  plugins =
    let
      inherit (pkgs) zathuraPkgs;
    in
    [
      zathuraPkgs.zathura_pdf_poppler
      zathuraPkgs.zathura_pdf_mupdf
      zathuraPkgs.zathura_djvu
      zathuraPkgs.zathura_ps
      zathuraPkgs.zathura_cb
    ];
}
