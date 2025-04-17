{ stdenv, fetchFromGitHub }:
let
  inherit (stdenv) mkDerivation;
in
mkDerivation {
  pname = "OpenEq";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "EvoXCX";
    repo = "EasyEffect-Preset";
    rev = "main";
    sha256 = "0yd83izcvk0m17sz8icsvxvjwb3mjlzrazsiwn7a14lfysjjr0cn";
  };

  buildInputs = [ ];

  installPhase = ''
    mkdir -p $out
    cp $src/'OpenEQ + Loudness.json' $out/
  '';
}
