{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (builtins) elem;
  inherit (lib) mkIf getExe filterAttrs;

  bat = getExe pkgs.bat;

  cfg = config.home;
in
{
  config = mkIf (!cfg.disableModule) {
    home.sessionVariables =
      {
        MANPAGER = "sh -c 'col --no-backspaces --spaces | ${bat} --language=man --plain'";
        MANROFFOPT = "-c";
      }
      |> filterAttrs (key: value: !(elem key cfg.disableVariables));
  };
}
