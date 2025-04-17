{
  bat-extras,
  writeShellApplication,
}:
let
  inherit (builtins) readFile;
in
writeShellApplication {
  name = "help";

  runtimeInputs = [
    bat-extras.core
  ];

  text = readFile ./help.sh;
}
