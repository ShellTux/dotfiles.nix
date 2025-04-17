{
  coreutils,
  home-manager,
  nixos-rebuild,
  writeShellApplication,
}:
let
  inherit (builtins) readFile;
in
writeShellApplication {
  name = "dotfiles-check";

  runtimeInputs = [
    coreutils
    home-manager
    nixos-rebuild
  ];

  text = readFile ./dotfiles-check.sh;
}
