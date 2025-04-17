{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool;

  cfg = config.virtualisation.libvirtd;
in
{
  options.virtualisation.libvirtd = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    virtualisation.libvirtd = mkDefault {
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;
        ovmf =
          let
            OVMF = pkgs.OVMF.override {
              secureBoot = true;
              tpmSupport = true;
            };
          in
          {
            enable = true;
            packages = [ OVMF.fd ];
          };
      };
    };
  };
}
