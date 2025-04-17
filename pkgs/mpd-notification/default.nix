{
  coreutils,
  mpc,
  notify-music,
  writeShellApplication,
}:
let
  inherit (builtins) readFile;
in
writeShellApplication {
  name = "mpd-notification";

  runtimeInputs = [
    coreutils
    mpc
    notify-music
  ];

  text = readFile ./mpd-notification.sh;
}
