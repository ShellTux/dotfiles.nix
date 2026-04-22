{ lib, final, ... }:
let
  inherit (lib) pipe;
  inherit (final.flake) dirsNames;
in
dirPath:
pipe dirPath [
  dirsNames
  (map (name: "${dirPath}/${name}"))
]
