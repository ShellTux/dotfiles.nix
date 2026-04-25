{ lib, ... }:
let
  inherit (lib) mkIf;
in
{ enable, flavour, ... }:
expected-flavour: mkIf (enable && flavour == expected-flavour)
