{
  lib,
  ...
}:
let
  inherit (lib) mkDefault;
in
{
  programs.nixvim.plugins.lsp.servers.tinymist = mkDefault {
    settings = {
      exportPdf = "onSave";
      formatterMode = "typstyle";
    };
  };
}
