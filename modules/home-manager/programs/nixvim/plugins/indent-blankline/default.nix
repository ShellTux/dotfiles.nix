{
  lib,
  ...
}:
let
  inherit (lib) mkDefault;
in
{
  programs.nixvim.plugins.indent-blankline.settings = mkDefault {
    exclude = {
      buftypes = [
        "terminal"
        "quickfix"
      ];
      filetypes = [
        ""
        "''"
        "checkhealth"
        "gitcommit"
        "help"
        "lspinfo"
        "man"
        "packer"
        "TelescopePrompt"
        "TelescopeResults"
        "yaml"
      ];
    };
    indent.tab_char = "";
  };
}
