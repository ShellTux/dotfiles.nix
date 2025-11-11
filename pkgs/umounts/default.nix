{ writeShellApplication }:
let
  inherit (builtins) readFile;
in
writeShellApplication {
  name = "umounts";

  runtimeInputs = [ ];

  text = readFile ./umounts.sh;
}
