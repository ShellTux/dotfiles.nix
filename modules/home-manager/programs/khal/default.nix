{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool;

  cfg = config.programs.khal;
in
{
  options.programs.khal = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    programs.khal = mkDefault {
      settings = {
        default = {
          default_event_duration = "30m";
          highlight_event_days = true;
          timedelta = "5d";
        };

        view = {
          frame = "color";
          theme = "dark";
          event_view_always_visible = true;
          dynamic_days = false;
          min_calendar_display = 2;
        };
      };
    };
  };
}
