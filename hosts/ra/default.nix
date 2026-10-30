{ ... }:
{
  imports = [
    ./configuration.nix
    ./disko-config.nix
    ./hardware.nix
    ./server.crypt.nix
  ];

  sops.defaultSopsFile = ./secrets.yaml;
}
