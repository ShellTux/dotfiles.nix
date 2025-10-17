{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    mkOption
    mkIf
    mkDefault
    genAttrs
    ;
  inherit (lib.types) bool;

  cfg = config.programs.zathura;
in
{
  options.programs.zathura = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    programs.zathura = mkDefault {
      options = {
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
    };

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
  };
}
