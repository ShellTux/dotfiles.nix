{ config, lib, ... }:
let
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool;

  cfg = config.programs.keepassxc;
in
{
  options.programs.keepassxc = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    programs.keepassxc.settings = {
      GUI = {
        MinimizeOnClose = mkDefault true;
        ShowTrayIcon = mkDefault true;
      };

      Security = {
        ClearClipboard = mkDefault true;
      };

      PasswordGenerator = {
        EASCII = mkDefault true;
        Length = mkDefault 64;
        LowerCase = mkDefault true;
        Numbers = mkDefault true;
        SpecialChars = mkDefault true;
        UpperCase = mkDefault true;
      };
    };
  };
}
