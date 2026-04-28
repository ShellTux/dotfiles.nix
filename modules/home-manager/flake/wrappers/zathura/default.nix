{ config, lib, ... }:
let
  inherit (lib) mkIf genAttrs;

  cfg = config.flake.wrappers.zathura;
in
mkIf cfg.enable {
  home.packages = [ cfg.package ];

  xdg.mimeApps.defaultApplications = genAttrs [
    "application/illustrator"
    "application/oxps"
    "application/pdf"
    "application/postscript"
    "application/vnd.comicbook+zip"
    "application/vnd.comicbook-rar"
    "application/vnd.ms-xpsdocument"
    "application/x-bzdvi"
    "application/x-bzpdf"
    "application/x-bzpostscript"
    "application/x-cb7"
    "application/x-cbr"
    "application/x-cbt"
    "application/x-cbz"
    "application/x-dvi"
    "application/x-ext-cb7"
    "application/x-ext-cbr"
    "application/x-ext-cbt"
    "application/x-ext-cbz"
    "application/x-ext-djv"
    "application/x-ext-djvu"
    "application/x-ext-dvi"
    "application/x-ext-eps"
    "application/x-ext-pdf"
    "application/x-ext-ps"
    "application/x-gzdvi"
    "application/x-gzpdf"
    "application/x-gzpostscript"
    "application/x-xzpdf"
    "image/vnd.djvu+multipage"
    "image/x-bzeps"
    "image/x-eps"
    "image/x-gzeps"
  ] (_: "org.pwmt.zathura.desktop");
}
