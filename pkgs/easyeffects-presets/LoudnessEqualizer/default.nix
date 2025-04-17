{ stdenv, fetchFromGitHub }:
let
  inherit (stdenv) mkDerivation;
in
mkDerivation {
  pname = "LoudnessEqualizer";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "Digitalone1";
    repo = "EasyEffects-Presets";
    rev = "master";
    sha256 = "0sbx0jwvl1xgj0kzx1sywdh2w44l5ah150d1aync3cwffg495m2k";
  };

  buildInputs = [ ];

  installPhase = ''
    mkdir -p $out
    cp $src/*.json $out/
  '';
}
