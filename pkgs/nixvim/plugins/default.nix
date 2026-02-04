{ ... }:
{
  imports = [
    ./auto-save
    ./bufferline
    ./cloak
    ./cmp
    ./codesnap
    ./colorizer
    ./gitsigns
    ./indent-blankline
    ./jdtls
    ./lalrpop-vim
    ./lastplace
    ./lsp
    ./lsp-lines
    ./lualine
    ./luasnip
    ./multicursors
    ./noice
    ./notify
    ./nvim-snippets
    ./render-markdown
    ./rustaceanvim
    ./screenkey
    ./telescope
    ./vim-easy-align
    ./vim-llvm
    ./vim-polyglot
    ./vim-visual-multi
    ./web-devicons
  ];

  plugins = {
    auto-save.enable = true;
    bufferline.enable = true;
    chadtree.enable = true;
    cloak.enable = true;
    cmp.enable = true;
    codesnap.enable = true;
    colorizer.enable = true;
    friendly-snippets.enable = true;
    fugitive.enable = true;
    gitsigns.enable = true;
    indent-blankline.enable = true;
    jdtls.enable = true;
    lastplace.enable = true;
    lsp.enable = true;
    lsp-format.enable = true;
    lsp-lines.enable = true;
    lualine.enable = true;
    luasnip.enable = true;
    markdown-preview.enable = true;
    noice.enable = true;
    notify.enable = true;
    nvim-autopairs.enable = true;
    nvim-snippets.enable = true;
    render-markdown.enable = true;
    rustaceanvim.enable = true;
    telescope.enable = true;
    tmux-navigator.enable = true;
    todo-comments.enable = true;
    transparent.enable = true;
    treesitter.enable = true;
    twilight.enable = true;
    typst-vim.enable = true;
    undotree.enable = true;
    vim-surround.enable = true;
    vimtex.enable = true;
    web-devicons.enable = true;
    which-key.enable = true;
  };
}
