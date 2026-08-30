{ ... }:
{
  imports = [
    ./configuration.nix
    ./disko-config.nix
    ./hardware.nix
    ./temp-config.nix # NOTE: Use this file for temporary config
  ];

  sops.defaultSopsFile = ./secrets.yaml;
}
