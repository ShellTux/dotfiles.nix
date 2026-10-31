{
  stdenvNoCC,
  gzip,
  gnutar,
}:

stdenvNoCC.mkDerivation {
  pname = "jdownloader2";
  version = "latest";

  src = ./jownloader2.tar.gz;

  nativeBuildInputs = [
    gzip
    gnutar
  ];

  dontUnpack = true;

  installPhase = ''
    mkdir --parents $out/share/jdownloader
    cp --archive . $out/share/jdownloader
  '';
}
