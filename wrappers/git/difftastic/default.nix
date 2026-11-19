{
  lib,
  config,
  pkgs,
  ...
}:
lib.mkIf (config.flavour == "difftastic") {
  settings = {
    alias = {
      dlog = "-c diff.external=difft log --ext-diff";
      dshow = "-c diff.external=difft show --ext-diff";
      ddiff = "-c diff.external=difft diff";

      ds = "dshow";
      dft = "dft";
    };
    diff = {
      external = "difft";
      tool = "difftastic";
    };
    pager.difftool = true;
    "difftool \"difftastic\"".cmd =
      ''difft "$MERGED" "$LOCAL" "abcdef1" "100644" "$REMOTE" "abcdef2" "100644"'';
    difftool.prompt = false;
  };

  runtimePkgs = [ pkgs.difftastic ];
}
