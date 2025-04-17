{
  lib,
  ...
}:
let
  inherit (lib) mkDefault;
in
{
  imports = [
    ./nil_ls
    ./rust_analyzer
    ./tinymist
  ];

  config.programs.nixvim.plugins.lsp.servers = mkDefault {
    bashls.enable = true;
    clangd.enable = true;
    dockerls.enable = true;
    gopls.enable = true;
    jsonls.enable = true;
    lua_ls.enable = true;
    marksman.enable = true;
    nil_ls.enable = true;
    pyright.enable = true;
    rust_analyzer.enable = true;
    texlab.enable = true;
    tinymist.enable = true;
    ts_ls.enable = true;
    yamlls.enable = true;
    zls.enable = true;
  };
}
