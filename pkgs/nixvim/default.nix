{ ... }:
{
  imports = [
    ./autoCmd
    ./autoGroups
    ./colorschemes
    ./extraConfigLua
    ./globals
    ./keymaps
    ./lsp
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
