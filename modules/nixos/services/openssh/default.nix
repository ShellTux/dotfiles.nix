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
        AllowUsers = mkDefault null;
        MaxAuthTries = mkDefault 3;
        PasswordAuthentication = mkDefault false;
        PermitRootLogin = mkDefault "no";
        PerSourcePenalties = mkDefault "crash:3600s authfail:3600s max:86400s";
        PrintMotd = mkDefault true;
        PubkeyAuthentication = mkDefault "yes";
        X11Forwarding = mkDefault false;
      };
    };

    programs.rust-motd.settings.service_status.Sshd = "sshd";
  };
}
