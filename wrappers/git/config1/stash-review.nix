{
  coreutils,
  git,
  writeShellApplication,
}:
let
  inherit (builtins) readFile;
in
writeShellApplication {
  name = "git-stash-review";

  runtimeInputs = [
    coreutils
    git
  ];

  text = readFile ./stash-review.sh;
}
