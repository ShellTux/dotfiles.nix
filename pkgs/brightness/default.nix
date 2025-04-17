{
  brightnessctl,
  coreutils,
  gawk,
  gnused,
  libnotify,
  writeShellApplication,
}:
let
  inherit (builtins) readFile;
in
writeShellApplication {
  name = "brightness";

  runtimeInputs = [
    brightnessctl
    coreutils
    gawk
    gnused
    libnotify
  ];

  text = readFile ./brightness.sh;
}
