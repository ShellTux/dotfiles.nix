{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkDefault getExe;

  jdtls = getExe pkgs.jdt-language-server;
in
{
  programs.nixvim.plugins.jdtls.settings.cmd = mkDefault [
    "${jdtls}"
    "-data"
    "${config.xdg.cacheHome}/jdtls/workspace"
    "-configuration"
    "${config.xdg.cacheHome}/jdtls/config"
  ];
}
