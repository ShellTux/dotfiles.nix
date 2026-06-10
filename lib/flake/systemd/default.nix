{ lib, ... }:
let
  inherit (builtins) concatStringsSep stringLength filter;
  inherit (lib) pipe splitString getExe;
in
{
  mkRsyncBackupServiceAndTimer =
    {
      src,
      dst ? "/backup/${src}",
      keep ? 3,
      excludes ? [ ],
      timerConfig ? {
        OnCalendar = "*-*-* 02:00:00";
        RandomizedDelaySec = "1h";
        Persistent = true;
      },

      rsync,
      writeShellScript,
    }:
    let
      excludeArgs = concatStringsSep " " (map (e: "--exclude='${e}'") excludes);
      escapedSrc = pipe src [
        (splitString "/")
        (filter (s: stringLength s > 0))
        (concatStringsSep "-")
      ];
      serviceName = "rsync-${escapedSrc}-backup";
      scriptName = "${serviceName}-script";

      script = writeShellScript scriptName ''
        set -e

        SRC="${src}"
        BASE="${dst}"
        KEEP="${toString keep}"

        mkdir --parents "$BASE"

        echo "== Rotating snapshots (keep $KEEP) =="

        # delete oldest
        [ -d "$BASE/snapshot.$((KEEP-1))" ] && rm -rf "$BASE/snapshot.$((KEEP-1))"

        # shift snapshots
        i=$((KEEP-1))
        while [ $i -gt 0 ]
        do
          prev=$((i-1))

          if [ -d "$BASE/snapshot.$prev" ]
          then
            mv "$BASE/snapshot.$prev" "$BASE/snapshot.$i"
          fi

          i=$prev
        done

        # determine link-dest
        if [ -d "$BASE/snapshot.1" ]
        then
          LINK_DEST="--link-dest=$BASE/snapshot.1"
        else
          LINK_DEST=""
        fi

        echo "== Running rsync =="

        ${getExe rsync} --archive --delete \
          $LINK_DEST \
          ${excludeArgs} \
          "$SRC/" "$BASE/snapshot.0/"

        echo "== Done =="
      '';
    in
    {
      services.${serviceName} = {
        Unit.Description = "Simple rsync backup (${src})";

        Service = {
          Type = "oneshot";
          ExecStart = script;

          # Optional: lower impact on system
          Nice = 10;
          IOSchedulingClass = "best-effort";
          IOSchedulingPriority = 7;
        };
      };

      timers.${serviceName} = {
        Unit.Description = "Run rsync backup timer (${src})";
        Timer = timerConfig;
        Install.WantedBy = [ "timers.target" ];
      };
    };
}
