{ flake-pkgs, ... }:
let
  inherit (builtins) fromJSON readFile;

  OpenEq = flake-pkgs.easyeffects-preset-openeq;
in
{
  services.easyeffects.extraPresets.OpenEq = readFile "${OpenEq}/OpenEQ + Loudness.json" |> fromJSON;
}
