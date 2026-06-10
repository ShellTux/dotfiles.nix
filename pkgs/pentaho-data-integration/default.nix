{
  extraJars ? [ ],
  fetchurl,
  glib,
  jdk17,
  makeDesktopItem,
  makeWrapper,
  stdenv,
  symlinkJoin,
  unzip,
  ...
}:
let
  inherit (stdenv) mkDerivation shell;

  pname = "pentaho-data-integration";
  version = "9.4.0.0-343";

  finalExtraJars = map fetchurl extraJars;

  pentaho = mkDerivation {
    name = "${pname}-src-${version}";

    src = fetchurl {
      url = "https://github.com/ambientelivre/legacy-pentaho-ce/releases/download/pdi-ce-${version}/pdi-ce-${version}.zip";
      hash = "sha256-5oBPrhqapmuS54Hpsug11y1Wpq3FPcA+QpqEeZGjNOg=";
    };

    nativeBuildInputs = [
      unzip
      makeWrapper
    ];

    installPhase = ''
      mkdir -p $out/share
      cp -r . $out/share/data-integration

      for jar in ${toString finalExtraJars}
      do
          cp -v "$jar" "$out/share/data-integration/lib/$(basename "$jar")"
      done

      mkdir -p $out/bin

      cat > $out/bin/pdi <<EOF
      #!${shell}

      export PENTAHO_STATE_DIR=\$${XDG_STATE_HOME:-\$HOME/.local/state}/pentaho
      export PDI_LOG_DIR=\$PENTAHO_STATE_DIR/logs

      mkdir -p "\$PDI_LOG_DIR"


      cd $out/share/data-integration
      exec ./spoon.sh "\$@"
      EOF

      cat > $out/bin/kitchen <<EOF
      #!${shell}

      export PENTAHO_STATE_DIR=\$${XDG_STATE_HOME:-\$HOME/.local/state}/pentaho
      export PDI_LOG_DIR=\$PENTAHO_STATE_DIR/logs

      mkdir -p "\$PDI_LOG_DIR"

      cd $out/share/data-integration
      exec ./kitchen.sh "\$@"
      EOF

      chmod +x $out/bin/pdi $out/bin/kitchen
    '';

    postFixup = ''
      wrapProgram $out/bin/pdi \
        --set JAVA_HOME ${jdk17} \
        --prefix PATH : ${jdk17}/bin \
        --prefix LD_LIBRARY_PATH : ${glib.out or glib}/lib \
        --set PDI_LOG_DIR '\$${XDG_STATE_HOME:-$HOME/.local/state}/pentaho'

      # Wrap kitchen
      wrapProgram $out/bin/kitchen \
        --set JAVA_HOME ${jdk17} \
        --prefix PATH : ${jdk17}/bin \
        --prefix LD_LIBRARY_PATH : ${glib.out or glib}/lib \
        --set PDI_LOG_DIR '\$${XDG_STATE_HOME:-$HOME/.local/state}/pentaho'
    '';

    meta = {
      description = "Pentaho Data Integration (Spoon)";
      mainProgram = "pdi";
    };

  };

  spoonDesktop = makeDesktopItem {
    name = "pentaho-pdi";
    desktopName = "Pentaho Data Integration";
    genericName = "ETL Tool";
    exec = "${pentaho}/bin/pdi";
    icon = "system-run";
    categories = [ "Development" ];
    terminal = false;
  };

  kitchenDesktop = makeDesktopItem {
    name = "pentaho-kitchen";
    desktopName = "Pentaho Data Integration";
    genericName = "ETL Tool";
    exec = "${pentaho}/bin/kitchen";
    icon = "system-run";
    categories = [ "Development" ];
    terminal = false;
  };

in
symlinkJoin {
  name = "${pname}-${version}";
  meta.mainProgram = "pdi";
  paths = [
    pentaho
    spoonDesktop
    kitchenDesktop
  ];
}
