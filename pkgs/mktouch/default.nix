{ coreutils, writeShellApplication }:
let
  inherit (builtins) readFile;
in
writeShellApplication {
  name = "mktouch";

  runtimeInputs = [
    coreutils
  ];

  text = readFile ./mktouch.sh;
}
