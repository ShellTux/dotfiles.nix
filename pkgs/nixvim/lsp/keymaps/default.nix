{ ... }: {
  lsp.keymaps = [
    {
      key = "gd";
      lspBufAction = "definition";
    }
    {
      key = "gD";
      lspBufAction = "references";
    }
    {
      key = "gt";
      lspBufAction = "type_definition";
    }
    {
      key = "gi";
      lspBufAction = "implementation";
    }
    {
      key = "K";
      lspBufAction = "hover";
    }
    {
      action.__raw = "function() vim.diagnostic.jump({ count=-1, float=true }) end";
      key = "g]";
    }
    {
      action.__raw = "function() vim.diagnostic.jump({ count=1, float=true }) end";
      key = "g[";
    }
    {
      action = "<CMD>LspStop<Enter>";
      key = "<leader>Lsto";
    }
    {
      action = "<CMD>LspStart<Enter>";
      key = "<leader>Lsta";
    }
    {
      action = "<CMD>LspRestart<Enter>";
      key = "<leader>Lr";
    }
    {
      action.__raw = "require('telescope.builtin').lsp_definitions";
      key = "gd";
    }
    {
      action = "<CMD>Lspsaga hover_doc<Enter>";
      key = "K";
    }
  ];
}
