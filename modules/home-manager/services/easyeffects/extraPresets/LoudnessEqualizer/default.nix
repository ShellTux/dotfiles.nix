{ inputs, lib, ... }:
let
  inherit (builtins) fromJSON readFile listToAttrs;
  inherit (lib) pipe nameValuePair;

  LoudnessEqualizer = inputs.easyeffects-presets.outPath;
in
{
  services.easyeffects.extraPresets =
    pipe
      [
        "LoudnessEqualizer"
        "LoudnessEqualizer-GTK"
        "LoudnessCrystalEqualizer"
        "LoudnessCrystalEqualizer-GTK"
        "LoudnessEqualizer-OldGate"
        # "LoudnessEqualizer-PE"
      ]
      [
        (map (
          preset:
          nameValuePair preset (
            pipe preset [
              (preset: "${LoudnessEqualizer}/${preset}.json")
              readFile
              fromJSON
            ]
          )
        ))
        listToAttrs
      ];
}
