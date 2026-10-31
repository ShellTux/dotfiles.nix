{
  bash,
  coreutils,
  jq,
  python3Packages,
  writeShellApplication,
}:
let
  inherit (builtins) readFile;
in
writeShellApplication {
  name = "speedtest-exporter";

  runtimeInputs = [
    bash
    coreutils
    jq
    python3Packages.speedtest-cli
  ];

  text = readFile ./script.sh;
}
