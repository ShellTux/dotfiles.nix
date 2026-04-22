{ lib, final, ... }:
let
  inherit (builtins) concatStringsSep;
  inherit (lib) pipe mkOption;
  inherit (lib.types) enum;
  inherit (final.flake) dirsNames;
in
path: default:
mkOption {
  inherit default;

  description = pipe path [
    dirsNames
    (map (flavour: "  - `${flavour}`"))
    (concatStringsSep "\n")
    (desc: ''
      Which flavour of configuration to pick:
      ${desc}
    '')
  ];

  type = pipe path [
    dirsNames
    enum
  ];
}
