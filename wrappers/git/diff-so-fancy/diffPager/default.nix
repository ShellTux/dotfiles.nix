{ diff-so-fancy, writeShellApplication }:
let
  inherit (builtins) readFile;
in
writeShellApplication {
  name = "git-diff-pager";

  runtimeInputs = [
    diff-so-fancy
  ];

  text = readFile ./diff-pager.sh;
}
