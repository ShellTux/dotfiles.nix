{ ... }:
{
  plugins.lsp.servers.rust_analyzer = {
    installCargo = true;
    installRustc = true;
    onAttach.function = ''
      vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
      if vim.g.lsp_on_attach ~= nil then
        vim.g.lsp_on_attach(client, bufnr)
      end
    '';
  };
}
