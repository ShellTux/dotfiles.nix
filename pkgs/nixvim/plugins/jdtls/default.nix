{ pkgs, ... }:
let
  inherit (pkgs.lib) getExe;

  jdtls = getExe pkgs.jdt-language-server;
in
{
  plugins.jdtls.settings.cmd = [
    "${jdtls}"
    "-data"
    ".jdtls/workspace"
    "-configuration"
    ".jdtls/config"
  ];
}
