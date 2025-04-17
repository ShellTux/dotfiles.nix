{ writeShellApplication }:
let
  inherit (builtins) readFile;
in
writeShellApplication {
  name = "PACKAGE_NAME";

  runtimeInputs = [ ];

  text = readFile ./PACKAGE_NAME.sh;
}
