{
  bat,
  coreutils,
  gnused,
  writeShellApplication,
}:
let
  inherit (builtins) readFile;
in
writeShellApplication {
  name = "create-module";

  runtimeInputs = [
    bat
    coreutils
    gnused
  ];

  text = readFile ./create-module.sh;
}
