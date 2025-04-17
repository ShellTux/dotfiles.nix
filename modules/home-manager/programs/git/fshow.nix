{
  bash,
  coreutils,
  diff-so-fancy,
  findutils,
  fzf,
  git,
  gnugrep,
  wclip,
  writeShellApplication,
}:
let
  inherit (builtins) readFile;
in
writeShellApplication {
  name = "fshow";

  runtimeInputs = [
    bash
    coreutils
    diff-so-fancy
    findutils
    fzf
    git
    gnugrep
    wclip
  ];

  text = readFile ./fshow.sh;
}
