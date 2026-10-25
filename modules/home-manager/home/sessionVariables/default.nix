{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (builtins) elem concatStringsSep;
  inherit (lib) mkIf getExe filterAttrs;

  bat = getExe pkgs.bat;

  cfg = config.home;
in
{
  config = mkIf (!cfg.disableModule) {
    home.sessionVariables =
      {
        LESSHISTFILE = "/dev/null";
        LESS = "--ignore-case --quit-if-one-screen --RAW-CONTROL-CHARS";
        MANPAGER = "sh -c 'col --no-backspaces --spaces | ${bat} --language=man --plain'";
        MANROFFOPT = "-c";
        CDPATH = concatStringsSep ":" [
          "."
          config.xdg.srcHome
          "${config.home.homeDirectory}/.local/src"
          config.xdg.configHome
          config.home.homeDirectory
          "${config.home.homeDirectory}/.local"
          "/etc"
        ];
      }
      |> filterAttrs (key: value: !(elem key cfg.disableVariables));
  };
}
