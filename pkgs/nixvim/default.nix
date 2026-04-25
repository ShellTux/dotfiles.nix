{ ... }:
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

  clipboard.providers = {
    wl-copy.enable = true;
    xclip.enable = true;
  };

  colorscheme = "tokyonight";
}
