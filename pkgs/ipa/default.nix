{
  coreutils,
  cowsay,
  gnugrep,
  writeShellApplication,
}:
let
  inherit (builtins) readFile;
in
writeShellApplication {
  name = "ipa";

  runtimeInputs = [
    coreutils
    cowsay
    gnugrep
  ];

  text = readFile ./ipa.sh;
}
