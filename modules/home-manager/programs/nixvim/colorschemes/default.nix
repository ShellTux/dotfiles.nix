{
  lib,
  ...
}:
let
  inherit (lib) mkDefault;
in
{
  programs.nixvim.colorschemes = mkDefault {
    catppuccin.enable = true;
    dracula.enable = true;
    everforest.enable = true;
    gruvbox.enable = true;
    kanagawa.enable = true;
    nightfox.enable = true;
    nord.enable = true;
    onedark.enable = true;
    tokyonight.enable = true;
    vscode.enable = true;
  };
}
