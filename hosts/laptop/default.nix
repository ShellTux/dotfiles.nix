{ ... }:
{
  imports = [
    ./configuration.nix
    ./hardware.nix
  ];

  sops.defaultSopsFile = ./secrets.yaml;
}
