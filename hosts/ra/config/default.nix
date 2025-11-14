{ ... }:
{
  imports = [
    ./fileSystems.crypt.nix
    ./networking
    ./programs
    ./security
    ./services
    ./users
  ];
}
