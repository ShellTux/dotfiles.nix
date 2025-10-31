{ pkgs, ... }:
{
  extraPlugins = [ pkgs.vimPlugins.vim-llvm ];
}
