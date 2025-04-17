{ ... }:
let
  inherit (builtins) map;
in
{
  hardware = {
    cpu.brand = "intel";
    enableRedistributableFirmware = true;
    graphics.enable = true;
    opentabletdriver.enable = true;
    logitech.wireless.enable = true;
    logitech.wireless.enableGraphical = true;
  };

  # TODO: Migrate to disko
  # disko.devices.disk.nvme0n1 = {
  # };

  boot = {
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "ahci"
        "nvme"
        "usb_storage"
        "sd_mod"
      ];
      luks.devices =
        let
          uuid = "4b11b6cb-1886-419c-83c4-db0590b7c427";
        in
        {
          "luks-${uuid}".device = "/dev/disk/by-uuid/${uuid}";
        };
      kernelModules = [ "kvm-intel" ];
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/16940278-3195-4d6f-924b-b7fb2e2353cd";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/D0C5-63EE";
      fsType = "vfat";
      options = [
        "fmask=0022"
        "dmask=0022"
      ];
    };
  };

  swapDevices =
    [
      "/dev/disk/by-partuuid/4d505ab1-327c-4b26-bc9b-dad48e4b7c1e"
    ]
    |> map (device: {
      inherit device;
      randomEncryption.enable = true;
    });
}
