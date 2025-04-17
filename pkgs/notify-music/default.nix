{
  bc,
  coreutils,
  fetch-music-data,
  playerctl,
  writeShellApplication,
}:
let
  inherit (builtins) readFile;
in
writeShellApplication {
  name = "notify-music";

  runtimeInputs = [
    bc
    coreutils
    fetch-music-data
    playerctl
  ];

  text = readFile ./notify-music.sh;
}
