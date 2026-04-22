{ lib, ... }:
let
  inherit (builtins) readDir attrNames;
  inherit (lib) pipe filterAttrs;
in
dirPath:
pipe dirPath [
  readDir
  (filterAttrs (_: type: type == "directory"))
  attrNames
]
