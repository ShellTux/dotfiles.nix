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
    hash = "sha256-gst5D7k7aNtUdcvMVLTZmTnBFc+vfdylBCv4dqKuWDo=";
  };

  buildInputs = [ ];

  installPhase = ''
    mkdir -p $out
    cp $src/*.json $out/
  '';
}
