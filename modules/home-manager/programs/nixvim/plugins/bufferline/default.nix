{
  lib,
  ...
}:
let
  inherit (builtins) readFile;
  inherit (lib) mkDefault;
in
{
  programs.nixvim.plugins.bufferline.settings.options = mkDefault {
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
