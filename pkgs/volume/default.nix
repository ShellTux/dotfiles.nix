{
  coreutils,
  gawk,
  gnugrep,
  libnotify,
  pulsemixer,
  wireplumber,
  writeShellApplication,
}:
let
  inherit (builtins) readFile;
in
writeShellApplication {
  name = "volume";

  runtimeInputs = [
    coreutils
    gawk
    gnugrep
    libnotify
    pulsemixer
    wireplumber
  ];

  text = readFile ./volume.sh;
}
