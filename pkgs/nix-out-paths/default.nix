{
  eza,
  writeShellApplication,
}:
let
  inherit (builtins) readFile;
in
writeShellApplication {
  name = "nix-out-paths";

  runtimeInputs = [
    eza
  ];

  text = readFile ./nix-out-paths.sh;
}
