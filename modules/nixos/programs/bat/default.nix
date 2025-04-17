{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (builtins) map;
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
      settings = {
        theme = "TwoDark";
        pager = "'less --RAW-CONTROL-CHARS --quit-if-one-screen --mouse'";
        # HACK: wrap spaces inside single quotes
        map-syntax =
          [
            "*.ino:C++"
            ".ignore:Git Ignore"
            "aliasrc:Bourne Again Shell (bash)"
            "bash_profile:Bourne Again Shell (bash)"
            "bashrc:Bourne Again Shell (bash)"
            "*.conf:INI"
            "dunstrc:INI"
          ]
          |> map (syntax: "'${syntax}'");
      };

      extraPackages =
        let
          inherit (pkgs) bat-extras;
        in
        [
          bat-extras.batdiff
          bat-extras.batgrep
          bat-extras.batman
          bat-extras.batpipe
          bat-extras.batwatch
        ];
    };

    environment = {
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
