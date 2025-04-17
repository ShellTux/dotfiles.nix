{
  lib,
  ...
}:
let
  inherit (lib) mkDefault;
in
{
  programs.nixvim.diagnostic.settings.virtual_lines.only_current_line = mkDefault true;
}
