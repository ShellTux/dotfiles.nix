{
  fetchurl,
  jdk17_headless,
  makeWrapper,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation {
  pname = "jdownloader2";
  version = "installer";

  src = fetchurl {
    url = "https://installer.jdownloader.org/JDownloader.jar";
    hash = "sha256-OIodAo5ly8Y5M6d43bySZ8FOfnhYOJzjGhC+cwit60A=";
  };

  nativeBuildInputs = [ makeWrapper ];

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/share/jdownloader
    cp $src $out/share/jdownloader/JDownloader.jar

    mkdir -p $out/bin

    makeWrapper ${jdk17_headless}/bin/java $out/bin/jdownloader2 \
      --add-flags "-jar $out/share/jdownloader/JDownloader.jar"
  '';
}
