{ modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  # hardware = {
  #   cpu.brand = "intel";
  #   graphics.enable = true;
  # };

  fileSystems = {
    "/" = {
      label = "root";
      fsType = "ext4";
    };
  };
}
