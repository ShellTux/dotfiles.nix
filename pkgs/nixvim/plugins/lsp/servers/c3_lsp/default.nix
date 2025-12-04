{ pkgs, ... }:
let
  c3lsp = pkgs.c3-lsp.meta.mainProgram;
in
{
  extraPlugins = pkgs.vimPlugins.nvim-treesitter.allGrammars ++ [
    pkgs.vimPlugins.nvim-treesitter-parsers.c3
  ];

  # plugins.treesitter.grammarPackages = [ pkgs.vimPlugins.nvim-treesitter-parsers.c3 ];
  plugins.treesitter.settings.parser_install_info.c3 = {
    install_info = {
      url = "https://github.com/c3lang/tree-sitter-c3";
      files = [
        "src/parser.c"
        "src/scanner.c"
      ];
      branch = "main";
    };
    sync_install = false; # Set to true if you want to install synchronously
    auto_install = true; # Automatically install when opening a file
    filetype = "c3"; # if filetype does not match the parser name
  };

  plugins.lsp.servers.c3_lsp = {
    package = pkgs.c3-lsp;
    packageFallback = true;
    cmd = [ c3lsp ];
  };
}
