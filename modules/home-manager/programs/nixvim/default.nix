{
  lib,
  ...
}:
let
  inherit (lib) mkOption mkDefault mkOverride;
  inherit (lib.types) str;
in
{
  imports = [
    ./autoCmd
    ./autoGroups
    ./colorschemes
    ./extraConfigLua
    ./globals
    ./keymaps
    ./match
    ./opts
    ./plugins
  ];

  # TODO: Add option to disable nixvim
  options.programs.nixvim = {
    leader-key = mkOption {
      description = "Leader key";
      type = str;
      default = " ";
    };
  };

  config = {
    programs.nixvim = {
      clipboard.providers = mkDefault {
        wl-copy.enable = true;
        xclip.enable = true;
      };

      colorscheme = mkOverride 100 "tokyonight";
    };

  };
}
