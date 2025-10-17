{ flake-pkgs, ... }:
let
  inherit (builtins) fromJSON readFile;

  LoudnessEqualizer = flake-pkgs.easyeffects-preset-loudness-equalizer;
in
{
  services.easyeffects.extraPresets = {
    LoudnessEqualizer = readFile "${LoudnessEqualizer}/LoudnessEqualizer.json" |> fromJSON;

    LoudnessCrystalEqualizer =
      readFile "${LoudnessEqualizer}/LoudnessCrystalEqualizer.json" |> fromJSON;

    LoudnessEqualizerOldGate =
      readFile "${LoudnessEqualizer}/LoudnessEqualizer-OldGate.json" |> fromJSON;

    LoudnessEqualizerPE = readFile "${LoudnessEqualizer}/LoudnessEqualizer-PE.json" |> fromJSON;
  };
}
