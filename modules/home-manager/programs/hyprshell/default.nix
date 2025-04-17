{ config, lib, ... }:
let
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool;

  cfg = config.programs.hyprshell;
in
{
  options.programs.hyprshell = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    programs.hyprshell = mkDefault {
      settings = {
        windows = {
          enable = true;
          overview = {
            enable = true;
            launcher.plugins.websearch.engines = [
              {
                name = "Unduck";
                url = "https://unduck.link?q={}";
                key = "d";
              }
              # {
              #   name = "DuckDuckGo";
              #   url = "https://duckduckgo.com/?q=%s";
              #   key = "d";
              # }
              {
                name = "Youtube";
                url = "https://www.youtube.com/results?search_query=%s";
                key = "y";
              }
            ];
          };
          switch.enable = true;
        };
      };
    };
  };
}
