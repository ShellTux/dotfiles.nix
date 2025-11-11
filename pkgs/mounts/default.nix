{ writeShellApplication }:
let
  inherit (builtins) readFile;
in
writeShellApplication {
  name = "mounts";

  runtimeInputs = [ ];

  text = readFile ./mounts.sh;
}
