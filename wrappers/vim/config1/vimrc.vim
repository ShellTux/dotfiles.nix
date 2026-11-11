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

" Create missing parent directories before writing {{{
function! s:CreateParentDirectories() abort
  if &buftype !=# '' || empty(expand('%'))
    return
  endif

  let l:dir = expand('%:p:h')
  if empty(l:dir) || isdirectory(l:dir)
    return
  endif

  if confirm(printf('Directory "%s" does not exist. Create it?', l:dir), "&Yes\n&No", 1) == 1
    call mkdir(l:dir, 'p')
  else
    throw 'Write cancelled: parent directory does not exist'
  endif
endfunction

augroup create_parent_directories
  autocmd!
  autocmd BufWritePre * call s:CreateParentDirectories()
augroup END
" }}}

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
