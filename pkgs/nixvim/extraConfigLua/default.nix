{ ... }:
let
  inherit (builtins) readFile concatStringsSep;
in
{
  extraConfigLua = concatStringsSep "\n" [
    (readFile ./random-colorscheme.lua)
    (readFile ./highlight-extra-whitespace.lua)
  ];
}
