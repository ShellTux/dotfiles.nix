{
  lib,
  config,
  pkgs,
  ...
}:
lib.mkIf (config.flavour == "diff-so-fancy") {
  settings = {
    pager.diff = lib.getExe (pkgs.callPackage ./diffPager { });
    core.pager = "diff-so-fancy | less --tabs=4 -RF";
    interactive.diffFilter = "diff-so-fancy --patch";
  };

  runtimePkgs = [ pkgs.diff-so-fancy ];
}
