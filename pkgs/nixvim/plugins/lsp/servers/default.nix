{ ... }:
{
  imports = [
    ./hls
    ./nil_ls
    ./rust_analyzer
    ./tinymist
  ];

  plugins.lsp.servers = {
    bashls.enable = true;
    clangd.enable = true;
    dockerls.enable = true;
    gopls.enable = true;
    hls.enable = true;
    jsonls.enable = true;
    lua_ls.enable = true;
    marksman.enable = true;
    nil_ls.enable = true;
    pyright.enable = true;
    texlab.enable = true;
    tinymist.enable = true;
    ts_ls.enable = true;
    yamlls.enable = true;
    zls.enable = true;
  };
}
