{ lib, ... }:
let
  inherit (lib) optional mkForce;
in
{
  mountDrive =
    {
      uuid,
      ro ? true,
    }:
    {
      device = "/dev/disk/by-uuid/${uuid}";
      fsType = "auto";

      options = (optional ro "ro") ++ [
        "nofail"
        "nosuid"
        "nodev"
      ];

      autoFormat = mkForce false;
      autoResize = mkForce false;
    };
}
