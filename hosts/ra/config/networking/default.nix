{ ... }:
{
  imports = [
    ./wireguard
  ];

  networking.hostFiles = [
    ./extraHosts.crypt.txt
  ];
}
