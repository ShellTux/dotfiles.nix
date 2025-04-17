{
  pkgs,
  ...
}:
let
  inherit (pkgs) callPackage;
in
{
  packages = rec {
    # easyeffects-presets = {
    #   LoudnessEqualizer = callPackage ./LoudnessEqualizer { };
    #   OpenEq = callPackage ./OpenEq { };
    # };

    easyeffects-preset-loudness-equalizer = callPackage ./LoudnessEqualizer { };
    easyeffects-preset-openeq = callPackage ./OpenEq { };
  };
}
