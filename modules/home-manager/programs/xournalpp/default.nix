{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkOption
    mkIf
    mkEnableOption
    ;
  inherit (lib.types) bool;

  cfg = config.programs.xournalpp;
in
{
  options.programs.xournalpp = {
    enable = mkEnableOption "Whether to install xournalpp";

    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    home.packages = [
      (pkgs.texliveSmall.withPackages (ps: [
        ps.scheme-basic

        ps.latex
        ps.pdftex
        ps.preview
        ps.scontents
        ps.standalone
        ps.varwidth
        ps.xcolor
      ]))
      pkgs.xournalpp
    ];

    xdg.configFile =
      let
        tex-path = template: "${pkgs.xournalpp}/share/xournalpp/resources/${template}";
      in
      {
        "xournalpp/default_template.tex".source = tex-path "default_template.tex";
        "xournalpp/legacy_template.tex".source = tex-path "legacy_template.tex";
      };
  };
}
