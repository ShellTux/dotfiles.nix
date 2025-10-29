{ inputs, ... }:
let
  inherit (builtins) fromJSON readFile;

  OpenEq = inputs.easyeffect-preset.outPath;
in
{
  services.easyeffects.extraPresets.OpenEq = readFile "${OpenEq}/OpenEQ + Loudness.json" |> fromJSON;
}
