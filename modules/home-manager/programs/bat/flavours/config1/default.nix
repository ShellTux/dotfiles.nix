{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkDefault;

  cfg = config.programs.bat;
in
mkIf (cfg.enable && cfg.flavour == "config1") {
  programs.bat = {
    config = {
      pager = "less --RAW-CONTROL-CHARS --quit-if-one-screen --mouse";
      theme = mkDefault "TwoDark";
      map-syntax = [
        "*.ino:C++"
        ".ignore:Git Ignore"
        "aliasrc:Bourne Again Shell (bash)"
        "bash_profile:Bourne Again Shell (bash)"
        "bashrc:Bourne Again Shell (bash)"
        "*.conf:INI"
        "dunstrc:INI"
      ];
    };

    extraPackages = [
      pkgs.bat-extras.batdiff
      pkgs.bat-extras.batgrep
      pkgs.bat-extras.batman
      pkgs.bat-extras.batpipe
      pkgs.bat-extras.batwatch
    ];
  };

  home = {
    shellAliases = {
      bathelp = "bat --plain --language=help";
    };
    sessionVariables = {
      MANPAGER = mkDefault "sh -c 'col --no-backspaces --spaces | bat --language man --plain'";
      MANROFFOPT = mkDefault "-c";
    };
  };
}
