{ lib, ... }:
let
  inherit (lib) mkDefault;
in
{
  boot = {
    loader.grub = {
      efiSupport = mkDefault true;
      efiInstallAsRemovable = mkDefault true;
    };
  };

  disko.devices.disk = {
    disk1 = {
      device = mkDefault "/dev/sda";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          boot = {
            name = "boot";
            size = "1M";
            type = "EF02";
          };
          esp = {
            name = "ESP";
            type = "EF00";
            size = "500M";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };
          encryptedSwap = {
            size = "4G";
            content = {
              type = "swap";
              randomEncryption = true;
            };
          };
          root = {
            name = "root";
            size = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
            };
          };
        };
      };
    };

    disk2 = {
      device = mkDefault "/dev/sdb";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          home = {
            name = "home";
            size = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/home";
            };
          };
        };
      };
    };
  };
}
