{
  coreutils,
  libnotify,
  writeShellApplication,
}:
let
  inherit (builtins) readFile;
in
writeShellApplication {
  name = "wpaperd-script";

  runtimeInputs = [
    coreutils
    libnotify
  ];

  text = readFile ./script.sh;
}
