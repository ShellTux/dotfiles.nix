{
  temurin-bin-8,
  temurin-bin-17,
  temurin-bin-21,
  prismlauncher,
}:
prismlauncher.override {
  jdks = [
    temurin-bin-8
    temurin-bin-17
    temurin-bin-21
  ];
}
