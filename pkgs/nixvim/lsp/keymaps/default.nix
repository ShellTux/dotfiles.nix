{ ... }: {
  lsp.keymaps = [
    {
      key = "gd";
      lspBufAction = "definition";
      options.desc = "Goto definition";
    }
    {
      key = "gD";
      lspBufAction = "references";
      options.desc = "References";
    }
    {
      key = "gt";
      lspBufAction = "type_definition";
      options.desc = "Goto type definition";
    }
    {
      key = "gi";
      lspBufAction = "implementation";
      options.desc = "Goto implementation";
    }
    {
      key = "K";
      lspBufAction = "hover";
      options.desc = "Documentation";
    }
    {
      action.__raw = "function() vim.diagnostic.jump({ count=1, float=true }) end";
      key = "g]";
      options.desc = "Goto next diagnostic";
    }
    {
      action.__raw = "function() vim.diagnostic.jump({ count=-1, float=true }) end";
      key = "g[";
      options.desc = "Goto previous diagnostic";
    }
    {
      action.__raw = "function() vim.diagnostic.jump({ count=1, float=true, severity = vim.diagnostic.severity.ERROR }) end";
      key = "g}";
      options.desc = "Goto next error";
    }
    {
      action.__raw = "function() vim.diagnostic.jump({ count=-1, float=true, severity = vim.diagnostic.severity.ERROR }) end";
      key = "g{";
      options.desc = "Goto previous error";
    }
    {
      action = "<CMD>LspStop<Enter>";
      key = "<leader>Lsto";
      options.desc = "Lsp Stop";
    }
    {
      action = "<CMD>LspStart<Enter>";
      key = "<leader>Lsta";
      options.desc = "Lsp Start";
    }
    {
      action = "<CMD>LspRestart<Enter>";
      key = "<leader>Lr";
      options.desc = "Lsp Restart";
    }
    {
      action.__raw = "require('telescope.builtin').lsp_definitions";
      key = "gd";
      options.desc = "[G]oto [D]efinition";
    }
    {
      action = "<CMD>Lspsaga hover_doc<Enter>";
      key = "K";
    }
  ];
}
