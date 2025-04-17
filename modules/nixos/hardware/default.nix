{ lib, ... }:
let
  inherit (lib) mkOption;
  inherit (lib.types) bool enum;
in
{
  imports = [
    ./graphics
    ./cpu
  ];

  options.hardware = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };

    cpu.brand = mkOption {
      description = "Cpu Brand";
      type = enum [
        "intel"
        "amd"
      ];
      default = null;
    };

    gpu.brand = mkOption {
      description = "Gpu Brand";
      type = enum [
        "amd"
        "intel"
        "nvidia"
      ];
      default = null;
    };
  };
}
