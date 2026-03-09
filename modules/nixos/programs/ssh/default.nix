{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool;

  cfg = config.programs.ssh;
in
{
  options.programs.ssh = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (!cfg.disableModule) {
    programs.ssh = {
      agentTimeout = mkDefault "1h";
      startAgent = !config.services.gnome.gcr-ssh-agent.enable;
    };
  };
}
