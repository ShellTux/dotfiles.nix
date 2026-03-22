{
  stdenvNoCC,
  fetchFromGitHub,
  libsForQt5,
}:
let
  inherit (stdenvNoCC) mkDerivation;
in
mkDerivation rec {
  pname = "sddm-lain-wired-theme";
  version = "0.9.1";

  src = fetchFromGitHub {
    owner = "lll2yu";
    repo = pname;
    rev = version;
    hash = "sha256-kvis9d9AfQk8tAzQeKTURl56Sqs3dttqPV3wNLvGEiw=";
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

  #  meta = with lib; {
  #    description = "The most minimalistic SDDM theme among all themes";
  #    homepage = "https://github.com/stepanzubkov/where-is-my-sddm-theme";
  #    license = licenses.mit;
  #    platforms = platforms.linux;
  #    maintainers = with maintainers; [ name-snrl ];
  #  };
}
