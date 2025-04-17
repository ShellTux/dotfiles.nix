{ writeShellApplication }:
let
  inherit (builtins) readFile;
in
writeShellApplication {
  name = "vman";

  text = readFile ./vman.sh;
}
