{ pkgs, ... }:
{
  keymaps = [
    {
      mode = [ "x" ];
      key = "ga";
      action = "<Plug>(EasyAlign)";
      options.desc = "EasyAlign";
    }
  ];

  extraPlugins = [ pkgs.vimPlugins.vim-easy-align ];
}
