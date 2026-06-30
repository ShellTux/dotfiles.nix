{
  stdenvNoCC,
  fetchFromGitHub,
  qt5,
}:
let
  inherit (stdenvNoCC) mkDerivation;
  inherit (qt5) qtmultimedia qtquickcontrols;
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
    qtmultimedia
    qtquickcontrols
  ];

  installPhase = ''
    mkdir -p "$out/share/sddm/themes/"
    cp -aR $src "$out/share/sddm/themes/sddm-lain-wired-theme"
  '';

  postFixup = ''
    mkdir -p $out/nix-support
    echo ${qtmultimedia} >> $out/nix-support/propagated-user-env-packages
    echo ${qtquickcontrols} >> $out/nix-support/propagated-user-env-packages
  '';
}
