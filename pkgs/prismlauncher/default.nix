{
  temurin-bin-8,
  temurin-bin,
  temurin-bin-17,
  temurin-bin-21,
  temurin-bin-25,
  temurin-bin-26,
  prismlauncher,
}:
prismlauncher.override {
  jdks = [
    temurin-bin-8
    temurin-bin
    temurin-bin-17
    temurin-bin-21
    temurin-bin-25
    temurin-bin-26
  ];
}
