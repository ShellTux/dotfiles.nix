{
  coreutils,
  hyprland,
  jq,
  noctalia,
  writeShellApplication,
}:
let
  inherit (builtins) readFile;
in
writeShellApplication {
  name = "hyprbinds";

  runtimeInputs = [
    coreutils
    hyprland
    jq
    noctalia
  ];

  text = readFile ./hyprbinds.sh;
}
