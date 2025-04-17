{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool;

  cfg = config.programs.bat;
in
{
  options.programs.bat = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) (mkDefault {
    programs.bat = {
      config = {
        pager = "less --RAW-CONTROL-CHARS --quit-if-one-screen --mouse";
        theme = "TwoDark";
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
        MANPAGER = "sh -c 'col --no-backspaces --spaces | bat --language man --plain'";
        MANROFFOPT = "-c";
      };
    };
  });
}
