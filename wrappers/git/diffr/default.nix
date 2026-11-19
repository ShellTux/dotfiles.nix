{
  lib,
  config,
  pkgs,
  ...
}:
lib.mkIf (config.flavour == "diffr") {
  settings = {
    core.pager = "diffr | less --tabs=4 -RF";
    interactive.diffFilter = "diffr";
  };

  runtimePkgs = [ pkgs.diffr ];
}
