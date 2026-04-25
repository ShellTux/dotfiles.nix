{ ... }:
{
  imports = [
    ./hls
    ./nil_ls
    ./rust_analyzer
    ./tinymist
  ];

  plugins.lsp.servers = {
    angularls.enable = true;
    arduino_language_server.enable = true;
    asm_lsp.enable = true;
    astro.enable = true;
    bashls.enable = true;
    clangd.enable = true;
    csharp_ls.enable = true;
    cssls.enable = true;
    dockerls.enable = true;
    elixirls.enable = true;
    glslls.enable = true;
    gopls.enable = true;
    hls.enable = true;
    html.enable = true;
    hyprls.enable = true;
    jsonls.enable = true;
    lua_ls.enable = true;
    marksman.enable = true;
    nil_ls.enable = true;
    ocamllsp.enable = true;
    pyright.enable = true;
    texlab.enable = true;
    tinymist.enable = true;
    ts_ls.enable = true;
    vala_ls.enable = true;
    yamlls.enable = true;
    zls.enable = true;
  };
}
