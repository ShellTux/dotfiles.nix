{ coreutils, writeShellApplication }:
let
  inherit (builtins) readFile;
in
writeShellApplication {
  name = "swap";

  runtimeInputs = [ coreutils ];

  text = readFile ./swap.sh;
}
