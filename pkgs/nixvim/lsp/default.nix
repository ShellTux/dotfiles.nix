{ ... }: {
  imports = [
    ./keymaps
    ./servers
  ];

  lsp.inlayHints.enable = true;
}
