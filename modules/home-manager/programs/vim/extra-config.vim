" vim: foldmethod=marker

" Options {{{
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
" }}}

" Keybindings {{{
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
" }}}
