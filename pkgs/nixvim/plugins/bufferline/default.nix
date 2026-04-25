{ ... }:
let
  inherit (builtins) readFile;
in
{
  plugins.bufferline.settings.options = {
    diagnostics = "nvim_lsp";
    diagnosticsIndicator = readFile ./diagnostics-indicator.lua;
    offsets = [ { filetype = "NvimTree"; } ];
    mode = "tabs";
    hover = {
      enabled = true;
      reveal = [ "close" ];
    };
  };
}
