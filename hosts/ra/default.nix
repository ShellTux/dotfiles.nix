{ ... }:
{
  imports = [
    ./configuration.nix
    ./disko-config.nix
    ./hardware.nix
  ];

  sops.defaultSopsFile = ./secrets.yaml;
}
