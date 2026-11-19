{
  bash,
  coreutils,
  diff-so-fancy,
  findutils,
  fzf,
  git,
  gnugrep,
  wl-clipboard,
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
    wl-clipboard
  ];

  text = readFile ./fshow.sh;
}
