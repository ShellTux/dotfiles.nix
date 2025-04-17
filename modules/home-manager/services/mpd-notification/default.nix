{
  config,
  lib,
  flake-pkgs,
  ...
}:
let
  inherit (lib)
    mkOption
    mkIf
    mkDefault
    mkEnableOption
    getExe
    ;
  inherit (lib.types) bool;

  cfg = config.services.mpd-notification;
in
{
  options.services.mpd-notification = {
    enable = mkEnableOption "Whether to enable mpd-notification";
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    services.mpd-notification = mkDefault { };

    systemd.user.services.mpd-notification = {
      Unit = {
        Description = "MPD Notification";
        Requires = "dbus.socket";
        PartOf = "graphical-session.target";
        # Do not require any service here! We do rely on mpd OR network (for
        # a remote mpd instance). So let the user care.
        # We want to order after, though. This makes sure the resource is
        # available on start and mpd-notification can cleanly disconnect on
        # system shutdown.
        After = [
          "mpd.service"
          "network.target"
          "network-online.target"
          # Order after notification daemons to make sure it is stopped before.
          "dunst.service"
          "xfce4-notifyd.service"
        ];
        ConditionUser = "!@system";
      };

      Service = {
        Restart = "on-failure";
        ExecStart = getExe flake-pkgs.mpd-notification;
        TimeoutSec = 3;
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
