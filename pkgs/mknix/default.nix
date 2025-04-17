{
  eza,
  installShellFiles,
  rustPlatform,
}:
let
  inherit (rustPlatform) buildRustPackage;
in
buildRustPackage {
  pname = "mknix";
  version = "0.0.1";

  src = ./.;

  nativeBuildInputs = [
    installShellFiles
  ];

  postInstall = ''
    ${eza}/bin/eza -lhA --tree
    installShellCompletion \
      --bash completions/bash/mknix.bash \
      --fish completions/fish/mknix.fish \
      --zsh completions/zsh/_mknix
  '';

  cargoLock.lockFile = ./Cargo.lock;
}
