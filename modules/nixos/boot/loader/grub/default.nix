{
  config,
  lib,
  ...
}:
let
  inherit (builtins) readFile;
  inherit (lib)
    mkIf
    mkDefault
    concatStrings
    mkOption
    ;
  inherit (lib.types) bool;

  cfg = config.boot.loader.grub;
in
{
  options.boot.loader.grub = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable) {
    boot.loader.grub = mkDefault {
      devices = [ "nodev" ];
      extraEntries = concatStrings [
        (readFile ./40_custom)
      ];
      efiSupport = true;
    };
  };
}
