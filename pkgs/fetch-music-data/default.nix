{
  coreutils,
  gawk,
  mpc,
  playerctl,
  writeShellApplication,
}:
let
  inherit (builtins) readFile;
in
writeShellApplication {
  name = "fetch-music-data";

  runtimeInputs = [
    coreutils
    gawk
    mpc
    playerctl
  ];

  text = readFile ./fetch-music-data.sh;
}
