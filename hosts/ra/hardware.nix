{ modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  # boot.loader.grub.device
  hardware = {
    cpu.brand = "intel";
    graphics.enable = true;
  };
}
