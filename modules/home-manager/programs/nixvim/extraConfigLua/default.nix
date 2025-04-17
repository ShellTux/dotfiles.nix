{
  lib,
  ...
}:
let
  inherit (builtins) readFile;
  inherit (lib) mkDefault mkMerge;
in
{
  programs.nixvim.extraConfigLua = mkMerge [
    (readFile ./random-colorscheme.lua)
    (readFile ./highlight-extra-whitespace.lua)
  ];
}
