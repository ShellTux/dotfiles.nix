{
  config,
  pkgs,
  wlib,
  lib,
  ...
}:
let
  inherit (lib) mkOption;
  inherit (lib.types) enum;
in
{
  imports = [ wlib.wrapperModules.vim ];

  options = {
    flavour = mkOption {
      type = enum [
        "none"
        "config1"
      ];
      default = "config1";
      description = ''
        Which flavour of configuration to pick:
        - `none`: No configuration, allowed to change
        - `config1`: Not allowed to change.
      '';
    };
  };

  config = {
    plugins =
      let
        inherit (pkgs) vimPlugins;
      in
      if config.flavour == "none" then
        [ ]
      else if config.flavour == "config1" then
        [
          vimPlugins.auto-pairs
          vimPlugins.vim-airline
        ]
      else
        null;

    vimrc =
      if config.flavour == "none" then
        ""
      else if config.flavour == "config1" then
        ''
          set background=dark
          set expandtab
          set ignorecase
          set number
          set shiftwidth=4
          set smartcase
          set tabstop=4

          colorscheme habamax
          set encoding=UTF-8
          set foldenable
          set hlsearch
          set incsearch
          set linebreak
          set listchars=tab:>-,trail:•,nbsp:~
          set scrolloff=999
          set secure
          set termguicolors
          set wildmenu
          syntax enable

          nnoremap <C-h> :nohlsearch<CR>
          nnoremap <Down> :resize +2<CR>
          nnoremap J mzJ`z
          nnoremap <leader>tc :tabclose<CR>
          nnoremap <Left> :vertical resize -2<CR>
          nnoremap <Right> :vertical resize +2<CR>
          nnoremap <Up> :resize -2<CR>
          nnoremap Y yg$
          vnoremap J :m '>+1<CR>gv=gv
          vnoremap K :m '<-2<CR>gv=gv
        ''
      else
        null;
  };
}
