{ coreutils, writeShellApplication }:
let
  inherit (builtins) readFile;
in
writeShellApplication {
  name = "repl";

  runtimeInputs = [
    coreutils
  ];

  text = readFile ./repl.sh;
}
