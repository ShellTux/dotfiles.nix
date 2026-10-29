{
  coreutils,
  git,
  writeShellApplication,
}:
let
  inherit (builtins) readFile;
in
writeShellApplication {
  name = "git-pwd";

  runtimeInputs = [
    coreutils
    git
  ];

  text = readFile ./pwd.sh;
}
