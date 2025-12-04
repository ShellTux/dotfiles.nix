{ ... }:
final: prev: {
  ncmpcpp = prev.ncmpcpp.override {
    clockSupport = true;
    visualizerSupport = true;
  };

  OVMF = prev.OVMF.override {
    secureBoot = true;
    tpmSupport = true;
  };

  rofi = prev.rofi.override {
    plugins = [ prev.rofi-emoji ];
  };

  prismlauncher = prev.prismlauncher.override {
    jdks =
      let
        inherit (prev.javaPackages.compiler) temurin-bin;
      in
      [
        temurin-bin.jdk-8
        temurin-bin.jdk-17
        temurin-bin.jdk-21
      ];
  };

  parallel-full = prev.parallel-full.override {
    willCite = true;
  };

}
