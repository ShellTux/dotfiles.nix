{
  coreutils,
  xdg-utils,
  writeShellApplication,
}:
let
  inherit (builtins) readFile;
in
writeShellApplication {
  name = "open";

  runtimeInputs = [
    coreutils
    xdg-utils
  ];

  text = readFile ./open.sh;
}
