{
  lib,
  ...
}:
let
  inherit (lib) mkDefault;
in
{
  programs.nixvim.match = mkDefault {
    ExtraWhitespace = "\\s\\+$";
  };
}
