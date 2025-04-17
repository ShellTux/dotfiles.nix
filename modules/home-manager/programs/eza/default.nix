{ lib, config, ... }:
let
  inherit (lib) mkIf mkOption mkDefault;
  inherit (lib.types) bool;

  cfg = config.programs.eza;
in
{
  options.programs.eza = {
    disableModule = mkOption {
      description = "Whether to disable eza configuration through Home Manager Module";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    programs.eza = mkDefault {
      git = true;
      icons = "auto";
      extraOptions = [
        "--across"
        "--color=automatic"
        "--color-scale=all"
        "--group-directories-first"
        "--binary"
        "--group"
        "--header"
      ];
    };

    # xdg.configFile."eza/theme.yml".source = ./theme.yml;

    home.shellAliases = {
      tree = "eza --color=auto --color-scale all --icons --tree --git-ignore";
    };

  };
}
