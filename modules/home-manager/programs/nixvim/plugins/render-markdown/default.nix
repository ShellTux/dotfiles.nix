{
  lib,
  ...
}:
let
  inherit (lib) mkDefault;
in
{
  programs.nixvim.plugins.render-markdown.settings = mkDefault {
    html.comment = {
      text = "󰆈";
      conceal = false;
    };
  };
}
