{
  lib,
  ...
}:
let
  inherit (lib) mkDefault;
in
{
  programs.nixvim.plugins.luasnip = mkDefault {
    settings = {
      enable_autosnippets = true;
      store_selection_keys = "<Tab>";
    };

    fromSnipmate = [
      { }
      { paths = ./snippets; }
    ];
  };
}
