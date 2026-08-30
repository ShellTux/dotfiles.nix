{
  lib,
  appimageTools,
  fetchurl,
}:
let
  inherit (lib) licenses maintainers;

  pname = "grist-desktop";
  version = "0.3.11";

  src = fetchurl {
    url = "https://github.com/gristlabs/grist-desktop/releases/download/v${version}/grist-desktop-${version}-linux-x86_64.AppImage";
    hash = "sha256-31DRuXv0CVMr/xYIbvVsyzlvGjgfnQic4b4jP6sMpVM=";
  };

  contents = appimageTools.extract { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install --mode 444 -D ${contents}/grist-desktop.desktop \
      $out/share/applications/grist-desktop.desktop
    substituteInPlace $out/share/applications/grist-desktop.desktop \
      --replace 'Exec=AppRun --no-sandbox' 'Exec=${pname}'
    cp -r ${contents}/usr/share/icons $out/share
  '';

  meta = {
    description = "Electron build of Grist, a self-contained spreadsheet/database app";
    homepage = "https://github.com/gristlabs/grist-desktop";
    license = licenses.asl20;
    maintainers = [ maintainers.pogobanane ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "grist-desktop";
  };
}
