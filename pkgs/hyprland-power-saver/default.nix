{
  coreutils,
  hyprland,
  libnotify,
  writeShellApplication,
}:
let
  inherit (builtins) readFile;
in
writeShellApplication {
  name = "hyprland-power-saver";

  runtimeInputs = [
    coreutils
    hyprland
    libnotify
  ];

  text = readFile ./hyprland-power-saver.sh;
}
