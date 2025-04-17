{
  lib,
  ...
}:
let
  inherit (lib) mkDefault;
in
{
  programs.nixvim.plugins.lsp.servers.rust_analyzer = mkDefault {
    installCargo = true;
    installRustc = true;
  };
}
