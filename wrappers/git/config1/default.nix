{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf getExe getExe';
  inherit (pkgs) callPackage;

  curl = getExe pkgs.curl;
  fshow = getExe (callPackage ./fshow.nix { });
  onefetch = getExe pkgs.onefetch;
  xdg-open = getExe' pkgs.xdg-utils "xdg-open";

  pager.diff = getExe (callPackage ./diffPager { });
in
mkIf (config.flavour == "config1") {
  settings = {
    inherit pager;

    branch.sort = "-committerdate";
    color = {
      ui = true;
      diff-highlight = {
        oldNormal = "red bold";
        oldHighlight = "red bold 52";
        newNormal = "green bold";
        newHighlight = "green bold 22";
      };

      diff = {
        meta = "11";
        frag = "magenta bold";
        func = "146 bold";
        commit = "yellow bold";
        old = "red bold";
        new = "green bold";
        whitespace = "red reverse";
      };

    };
    column.ui = "auto";
    commit = {
      template = "${./template}";
      verbose = true;
    };
    core = {
      editor = "nvim";
      autocrlf = "input";
      pager = "diff-so-fancy | less --tabs=4 -RF";
    };
    diff = {
      algorithm = "histogram";
      colorMoved = "plain";
      mnemonicPrefix = true;
      renames = true;
    };
    help.autoCorrect = "prompt";
    init.defaultBranch = "main";
    interactive.diffFilter = "diff-so-fancy --patch";
    rerere = {
      enable = true;
      autoupdate = true;
    };
    tag.sort = "version:refname";

    alias = rec {
      branch-delete = "branch --delete";
      br = "branch --format='%(HEAD) %(color:yellow)%(refname:short)%(color:reset) - %(contents:subject) %(color:green)(%(committerdate:relative)) [%(authorname)]' --sort=-committerdate";
      ci = "commit";
      co = "checkout";
      co- = "!git -c interactive.diffFilter='less --tabs=4 -RFX' checkout";
      conflict = "diff --name-only --diff-filter=U";
      cop = "co --patch";
      cop- = "co- --patch";
      cp = "cherry-pick";
      d- = "${d}-";
      dc = "diff-copy";
      d = "diff";
      diff- = "!git -c pager.diff='less --tabs=4 -RFX' -c interactive.diffFilter='less --tabs=4 -RFX' diff";
      diff-last = "!git diff HEAD~1 HEAD";
      diff-staged = "diff --staged";
      diff-staged- = "diff- --staged";
      diff-summary = "diff --stat";
      diff-word = "diff --word-diff --color-words";
      dl = "diff-last";
      dst- = "${dst}-";
      dst = "diff-staged";
      dsu = "diff-summary";
      dw = "diff-word";
      forget = "update-index --assume-unchanged";
      graph = "log --graph";
      ignore = "!${curl} -sL https://www.toptal.com/developers/gitignore/api/$@";
      last = "!git log -1 HEAD";
      lg1 = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)' --all";
      lg2 = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(auto)%d%C(reset)%n'' %C(white)%s%C(reset) %C(dim white)- %an%C(reset)'";
      lg = ''!git log --pretty=format:"%C(magenta)%h%Creset -%C(red)%d%Creset %s %C(dim green)(%cr) [%an]" --abbrev-commit -30'';
      lh = "log-history";
      log-history = "!${fshow}";
      open = "visit";
      patch = "!git --no-pager diff --no-color";
      project-summary = "summary";
      put = "push --set-upstream origin";
      serve = "daemon --verbose --export-all --base-path=.git --reuseaddr --strict-paths .git/";
      showconfig = "config --list";
      # FIX: Mismatch between input and output. See this: https://github.com/so-fancy/diff-so-fancy/issues/296
      sp- = "!git -c interactive.diffFilter='less --tabs=4 -RFX' sp";
      sp = "stage --patch";
      s = "status --short";
      stats = "show --stat";
      st = "status";
      summary = "!which ${onefetch} && ${onefetch}";
      sw = "switch -";
      touch = "!touch $@ && git add $@";
      unstage = "reset HEAD --";
      visit-branch = ''!${xdg-open} "https://`git config --get remote.origin.url | sed -E "s#(git@|git://|https?://|.git$)##g;s#:#/#"`/tree/`git branch --show-current`"'';
      visit = ''!${xdg-open} "https://`git config --get remote.origin.url | sed -E "s#(git@|git://|https?://|.git$)##g;s#:#/#"`"'';
      yolo = ''!git commit --message="$(curl --silent https://whatthecommit.com/index.txt)"'';
    };
  };

  runtimePkgs = [
    pkgs.diff-so-fancy
  ];
}
