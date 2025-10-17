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
    hash = "sha256-loEspfaOkqCO5VF/lT+VdSwud9+aRfT1CRXMzX4cqHk=";
  };

  buildInputs = [ ];

  installPhase = ''
    mkdir -p $out
    cp $src/'OpenEQ + Loudness.json' $out/
  '';
}
