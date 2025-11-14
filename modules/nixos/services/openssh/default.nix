{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool;

  cfg = config.services.openssh;
in
{
  options.services.openssh = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    services.openssh = {
      startWhenNeeded = true;
      ports = [ 22 ];

      settings = {
        PasswordAuthentication = mkDefault false;
        AllowUsers = mkDefault null;
        X11Forwarding = mkDefault false;
        PermitRootLogin = mkDefault "no";
        PrintMotd = mkDefault true;
      };
    };

    programs.rust-motd.settings.service_status.Sshd = "sshd";
  };
}
