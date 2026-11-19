{
  lib,
  config,
  pkgs,
  ...
}:
lib.mkIf (config.flavour == "delta") {
  settings = {
    alias.diff-side-by-side = "-c delta.features=side-by-side diff";
    core.pager = "delta";
    interactive.diffFilter = "delta --color-only";
    delta = {
      navigate = true;
      line-numbers = true;
    };
    merge.conflictStyle = "zdiff3";
  };

  runtimePkgs = [ pkgs.delta ];
}
