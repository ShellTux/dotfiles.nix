{
  coreutils,
  writeShellApplication,
}:
let
  inherit (builtins) readFile;
in
writeShellApplication {
  name = "stay";

  runtimeInputs = [
    coreutils
  ];

  text = readFile ./stay.sh;
}
