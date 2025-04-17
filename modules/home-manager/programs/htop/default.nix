{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool;

  cfg = config.programs.htop;
in
{
  options.programs.htop = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    programs.htop = mkDefault {
      settings =
        let
          inherit (config.lib.htop)
            fields
            leftMeters
            rightMeters
            bar
            text
            ;
        in
        {
          color_scheme = 6;
          cpu_count_from_one = 0;
          delay = 15;
          fields = [
            fields.PID
            fields.USER
            fields.PRIORITY
            fields.NICE
            fields.M_SIZE
            fields.M_RESIDENT
            fields.M_SHARE
            fields.STATE
            fields.PERCENT_CPU
            fields.PERCENT_MEM
            fields.TIME
            fields.COMM
          ];
          highlight_base_name = 1;
          highlight_megabytes = 1;
          highlight_threads = 1;
        }
        // (leftMeters [
          (bar "AllCPUs2")
          (bar "Memory")
          (bar "Swap")
          (text "Zram")
        ])
        // (rightMeters [
          (text "Tasks")
          (text "LoadAverage")
          (text "Uptime")
          (text "Systemd")
        ]);
    };
  };
}
