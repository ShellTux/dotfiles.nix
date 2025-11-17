{
  bat,
  curl,
  qrencode,
  writeShellApplication,
}:
let
  inherit (builtins) readFile;
in
writeShellApplication {
  name = "wg-conf";

  runtimeInputs = [
    bat
    curl
    qrencode
  ];

  text = readFile ./wg-conf.sh;
}
