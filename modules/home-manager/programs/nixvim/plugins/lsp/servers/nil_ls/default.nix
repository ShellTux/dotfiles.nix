{
  lib,
  ...
}:
let
  inherit (lib) mkDefault;
in
{
  programs.nixvim.plugins.lsp.servers.nil_ls.settings.nix.flake.autoArchive = mkDefault true;
}
