{
  wl-clipboard,
  xclip,
  writeShellApplication,
}:
let
  inherit (builtins) readFile;
in
writeShellApplication {
  name = "wclip";

  runtimeInputs = [
    wl-clipboard
    xclip
  ];

  text = readFile ./wclip.sh;
}
