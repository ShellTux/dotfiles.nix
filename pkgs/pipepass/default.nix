{ writeShellApplication }:
let
  inherit (builtins) readFile;
in
writeShellApplication {
  name = "pipepass";

  runtimeInputs = [ ];

  text = readFile ./pipepass.sh;
}
