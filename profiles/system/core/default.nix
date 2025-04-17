{ lib, ... }:
let
  inherit (lib) mkDefault mkOverride;
in
{
  # https://github.com/NixOS/nixpkgs/security/advisories/GHSA-m7pq-h9p4-8rr4
  systemd.shutdownRamfs.enable = mkOverride 0 false;

  system.stateVersion = mkDefault "25.05";
}
