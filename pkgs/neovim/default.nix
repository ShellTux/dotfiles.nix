{
  # TODO: Move home-manager nixvim to standalone

  imports = [
    ./colorschemes
    ./globals
    ./keymaps
    ./opts
    ./plugins
  ];

  colorscheme = "tokyonight";
}
