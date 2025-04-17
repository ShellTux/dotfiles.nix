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
      readFile "${LoudnessEqualizer}/LoudnessEqualizerOldGate.json" |> fromJSON;

    LoudnessEqualizerPE = readFile "${LoudnessEqualizer}/LoudnessEqualizerPE.json" |> fromJSON;
  };
}
