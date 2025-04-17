{
  fzf,
  coreutils,
  jq,
  mpvpaper,
  socat,
  writeShellApplication,
}:
let
  inherit (builtins) readFile;
in
writeShellApplication {
  name = "walld";

  runtimeInputs = [
    fzf
    coreutils
    jq
    mpvpaper
    socat
  ];

  text = readFile ./walld.sh;
}
