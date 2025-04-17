{
  stdenvNoCC,
  fetchFromGitHub,
  libsForQt5,
}:
let
  inherit (stdenvNoCC) mkDerivation;
in
mkDerivation rec {
  name = "sddm-lain-wired-theme";
  version = "0.9.1";

  src = fetchFromGitHub {
    owner = "lll2yu";
    repo = name;
    rev = version;
    sha256 = "0b0jqsxk9w2x7mmdnxipmd57lpj6sjj7il0cnhy0jza0vzssry4j";
  };

  dontWrapQtApps = true;
  dontBuild = true;

  buildInputs = [
    libsForQt5.qt5.qtmultimedia
    libsForQt5.qtquickcontrols
  ];

  installPhase = ''
    mkdir -p "$out/share/sddm/themes/"
    cp -aR $src "$out/share/sddm/themes/sddm-lain-wired-theme"
  '';

  postFixup = ''
    mkdir -p $out/nix-support
    echo ${libsForQt5.qt5.qtmultimedia} >> $out/nix-support/propagated-user-env-packages
    echo ${libsForQt5.qtquickcontrols} >> $out/nix-support/propagated-user-env-packages
  '';
}
