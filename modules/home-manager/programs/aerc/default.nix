{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkOption
    mkIf
    mkDefault
    getExe
    ;
  inherit (lib.types) bool;

  awk = getExe pkgs.gawk;
  bat = getExe pkgs.bat;
  less = getExe pkgs.less;
  mpv = getExe pkgs.mpv;
  imv = getExe pkgs.imv;
  zathura = getExe pkgs.zathura;

  cmd = command: ":${command}<Enter>";
  cfg = config.programs.aerc;
in
{
  options.programs.aerc = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    programs.aerc = mkDefault {
      extraConfig = {
        general.unsafe-accounts-conf = true;
        viewer.pager = "${less} -R";
        filters = {
          "text/plain" = "${pkgs.aerc}/libexec/aerc/filters/colorize";
          "text/calendar" = "${awk} --file ${pkgs.aerc}/libexec/aerc/filters/calendar";
          "text/html" = "${pkgs.aerc}/libexec/aerc/filters/html | ${pkgs.aerc}/libexec/aerc/filters/colorize";
          "text/*" = ''${bat} --force-colorization --paging=never --file-name="$AERC_FILENAME "'';
          "message/delivery-status" = "${pkgs.aerc}/libexec/aerc/filters/colorize";
          "message/rfc822" = "${pkgs.aerc}/libexec/aerc/filters/colorize";
          "application/x-sh" = "${bat} --force-colorization --paging=never --language sh";
          "application/pdf" = "${zathura} -";
          "audio/*" = "${mpv} -";
          "image/*" = "${imv} -";
        };
        ui = {
          border-char-horizontal = "━";
          border-char-vertical = "┃";
          index-format = "%-20.20D %-17.17n %Z %s";
          mouse-enabled = true;
          sidebar-width = 25;
          spinner = "[ ⡿ ],[ ⣟ ],[ ⣯ ],[ ⣷ ],[ ⣾ ],[ ⣽ ],[ ⣻ ],[ ⢿ ]";
          styleset-name = "nord";
          this-day-time-format = ''"           15:04"'';
          this-year-time-format = "Mon Jan 02 15:04";
          timestamp-format = "2006-01-02 15:04";
        };
        triggers.email-received = ''exec notify-send "New email from %n" "%s"'';
      };

      extraBinds = {
        global = {
          "<C-p>" = cmd "prev-tab";
          "<C-n>" = cmd "next-tab";
          "<C-t>" = cmd "term";
          "?" = cmd "help keys";
        };

        messages = {
          q = cmd "quit";

          j = cmd "next";
          "<Down>" = cmd "next";
          "<C-d>" = cmd "next 50%";
          "<C-f>" = cmd "next 100%";
          "<PgDn>" = cmd "next 100%";

          k = cmd "prev";
          "<Up>" = cmd "prev";
          "<C-u>" = cmd "prev 50%";
          "<C-b>" = cmd "prev 100%";
          "<PgUp>" = cmd "prev 100%";
          gg = cmd "select 0";
          G = cmd "select -1";

          J = cmd "next-folder";
          K = cmd "prev-folder";
          H = cmd "collapse-folder";
          L = cmd "expand-folder";

          "<C-PgDn>" = cmd "next-tab";
          "<C-PgUp>" = cmd "prev-tab";

          v = cmd "mark -t";
          V = cmd "mark -v";

          T = cmd "toggle-threads";

          "<Enter>" = cmd "view";
          l = cmd "view";
          d = cmd "prompt 'Really delete this message?' 'delete-message'";
          D = cmd "move Trash";
          A = cmd "archive flat";

          C = cmd "compose";

          rr = cmd "reply -a";
          rq = cmd "reply -aq";
          Rr = cmd "reply";
          Rq = cmd "reply -q";

          c = ":cf<space>";
          "$" = ":term<space>";
          "!" = ":term<space>";
          "|" = ":pipe<space>";

          "/" = ":search<space>-a<space>";
          "\\" = ":filter <space>";
          n = cmd "next-result";
          N = cmd "prev-result";
          "<Esc>" = cmd "clear";
        };

        "messages:folder=Drafts" = {
          "<Enter>" = ":recall<Enter>";
        };

        view = {
          "/" = ":toggle-key-passthrough <Enter> /";
          q = ":close<Enter>";
          O = ":open<Enter>";
          S = ":save<space>";
          "|" = ":pipe<space>";
          D = ":move Trash<Enter>";
          A = ":archive flat<Enter>";

          "<C-l>" = ":open-link <space>";

          f = ":forward <Enter>";
          rr = ":reply -a<Enter>";
          rq = ":reply -aq<Enter>";
          Rr = ":reply<Enter>";
          Rq = ":reply -q<Enter>";

          H = ":toggle-headers<Enter>";
          "<C-k>" = ":prev-part<Enter>";
          "<C-j>" = ":next-part<Enter>";
          J = ":next <Enter>";
          K = ":prev<Enter>";
        };

        "view::passthrough" = {
          "$noinherit" = "true";
          "$ex" = "<C-x>";
          "<Esc>" = ":toggle-key-passthrough<Enter>";
        };

        compose = {
          # Keybindings used when the embedded terminal is not selected in the compose view
          "$noinherit" = "true";
          "$ex" = "<C-x>";
          "<C-k>" = ":prev-field<Enter>";
          "<C-j>" = ":next-field<Enter>";
          "<A-p>" = ":switch-account -p<Enter>";
          "<A-n>" = ":switch-account -n<Enter>";
          "<tab>" = ":next-field<Enter>";
          "<C-p>" = ":prev-tab<Enter>";
          "<C-n>" = ":next-tab<Enter>";
        };

        "compose::editor" = {
          # Keybindings used when the embedded terminal is selected in the compose view
          "$noinherit" = "true";
          "$ex" = "<C-x>";
          "<C-k>" = ":prev-field<Enter>";
          "<C-j>" = ":next-field<Enter>";
          "<C-p>" = ":prev-tab<Enter>";
          "<C-n>" = ":next-tab<Enter>";
        };

        "compose::review" = {
          # Keybindings used when reviewing a message to be sent
          y = ":send <Enter>";
          n = ":abort<Enter>";
          p = ":postpone<Enter>";
          q = ":choose -o d discard abort -o p postpone postpone<Enter>";
          e = ":edit<Enter>";
          a = ":attach<space>";
          d = ":detach<space>";
        };

        terminal = {
          "$noinherit" = "true";
          "$ex" = "<C-x>";
          "<C-p>" = ":prev-tab<Enter>";
          "<C-n>" = ":next-tab<Enter>";
        };
      };
    };
  };
}
