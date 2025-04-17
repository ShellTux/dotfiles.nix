{
  bat,
  coreutils,
  writeShellApplication,
}:
let
  inherit (builtins) readFile;
in
writeShellApplication {
  name = "create-pkg";

  runtimeInputs = [
    bat
    coreutils
  ];

  text = readFile ./create-pkg.sh;
}
