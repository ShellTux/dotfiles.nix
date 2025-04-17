{
  config,
  lib,
  ...
}:
let
  inherit (builtins) elem;
  inherit (lib) mkIf filterAttrs;

  cfg = config.home;
in
{
  config = mkIf (!cfg.disableModule) {
    home.shellAliases =
      {
        bathelp = "bat --plain --language=help";
        chmod = "chmod --changes";
        chown = "chown --changes";
        cp = "cp --interactive --verbose";
        df = "df --human-readable";
        diff = "diff --color=auto";
        du = "du --human-readable";
        free = "free --human --wide --total";
        fzf = "fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}'";
        gdb = "gdb --tui";
        grep = "grep --colour=auto";
        install = "install --verbose";
        ip = "ip --color=auto";
        kernel = "uname --kernel-release";
        lower = ''tr "[:upper:]" "[:lower:]"'';
        lsblk-label = "lsblk -o name,fstype,mountpoint,label,partlabel,size";
        mkdir = "mkdir --parents --verbose";
        more = "less";
        mv = "mv --verbose";
        procs = "procs --watch-interval=.5 --watch";
        progress = "progress --wait-delay .5 --monitor-continuously";
        ":q" = "exit";
        rmdir = "rmdir --verbose";
        rm = "rm --verbose --one-file-system --interactive=once";
        rsync = "rsync --compress --verbose --human-readable --partial --progress";
        shred = "shred --verbose";
        sshfs = ''sshfs -o "compression=yes,reconnect"'';
        systemctl = "systemctl --lines=1000";
        upper = "tr \"[:lower:]\" \"[:upper:]\"";
        watch = "watch --color --interval 1";
      }
      |> filterAttrs (key: value: !(elem key cfg.disableAliases));
  };
}
