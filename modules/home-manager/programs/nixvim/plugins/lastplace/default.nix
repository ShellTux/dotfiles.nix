{
  lib,
  ...
}:
let
  inherit (lib) mkDefault;
in
{
  programs.nixvim.plugins.lastplace.settings = mkDefault {
    ignoreBuftype = [
      "quickfix"
      "nofix"
      "nofile"
      "help"
    ];
    ignoreFiletype = [
      "gitcommit"
      "gitrebase"
      "svn"
      "hgcommit"
    ];
    openFolds = true;
  };
}
