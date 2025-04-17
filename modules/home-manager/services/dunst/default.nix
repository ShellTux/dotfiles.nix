{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (builtins) readFile;
  inherit (lib)
    mkOption
    mkIf
    mkDefault
    getExe
    ;
  inherit (lib.types) bool;
  inherit (pkgs) writeShellApplication;

  script = getExe (writeShellApplication {
    name = "dunst-script";

    runtimeInputs = [
      pkgs.coreutils
      pkgs.pipewire
    ];

    runtimeEnv = {
      DUNST_SOUND_LOW = "dunst-sound-low-path";
      DUNST_SOUND_NORMAL = "dunst-sound-normal-path";
      DUNST_SOUND_CRITICAL = ./sounds/windows-xp-critical-stop.flac;
    };

    text = readFile ./script.sh;
  });

  cfg = config.services.dunst;
in
{
  options.services.dunst = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    services.dunst = {
      iconTheme = {
        name = "Adwaita";
        package = pkgs.adwaita-icon-theme;
        size = "32x32";
      };

      settings = {
        global = {
          alignment = "left";
          always_run_script = true;
          background = mkDefault "#285577";
          class = "Dunst";
          close_all = "ctrl+shift+space";
          close = "ctrl+shift+space";
          context = "ctrl+shift+period";
          corner_radius = 30;
          default_icon = "normal";
          ellipsize = "middle";
          enable_recursive_icon_lookup = false;
          follow = "keyboard";
          font = mkDefault "Droid Sans 12";
          foreground = mkDefault "#ffffff";
          format = "<u><span size='x-large' font_desc='Cantarell,mplus Nerd Font 9' weight='bold' foreground='#f9f9f9'>%s</span></u>\\n%b\\n<b>App</b>: %a\\n";
          frame_color = mkDefault "#aaaaaa";
          frame_width = 3;
          fullscreen = "delay";
          gap_size = 10;
          height = "(0, 700)";
          hide_duplicate_count = false;
          history = "ctrl+grave";
          history_length = 20;
          horizontal_padding = 8;
          icon_corner_radius = 20;
          icon_position = "left";
          icon_theme = mkDefault "Adwaita";
          ignore_dbusclose = false;
          ignore_newline = "no";
          indicate_hidden = "yes";
          layer = "top";
          line_height = 0;
          markup = "full";
          max_icon_size = 384;
          min_icon_size = 0;
          mouse_left_click = "close_current";
          mouse_middle_click = "do_action, close_current";
          mouse_right_click = "close_all";
          notification_limit = "0";
          offset = "(10,50)";
          origin = "top-right";
          padding = 8;
          progress_bar_frame_width = 2;
          progress_bar_height = 15;
          progress_bar_max_width = 300;
          progress_bar_min_width = 150;
          progress_bar = true;
          scale = 0;
          separator_color = mkDefault "auto";
          separator_height = 2;
          show_age_threshold = 60;
          show_indicators = "yes";
          sort = true;
          stack_duplicates = true;
          sticky_history = "yes";
          text_icon_padding = 0;
          timeout = 10;
          title = "Dunst";
          transparency = 0;
          vertical_alignment = "center";
          width = "(0, 1024)";
        };

        urgency_low = {
          inherit script;

          background = mkDefault "#222222";
          foreground = mkDefault "#888888";
          timeout = 5;
        };

        urgency_normal = {
          inherit script;
        };

        urgency_critical = {
          inherit script;

          background = mkDefault "#900000";
          foreground = mkDefault "#ffffff";
          frame_color = mkDefault "#ff0000";
          timeout = 0;
          default_icon = "critical";
        };

        help_notification = {
          msg_urgency = "normal";
          appname = "help";
          timeout = 30;
        };

        # fullscreen values
        # show: show the notifications, regardless if there is a fullscreen window opened
        # delay: displays the new notification, if there is no fullscreen window active
        #        If the notification is already drawn, it won't get undrawn.
        # pushback: same as delay, but when switching into fullscreen, the notification will get
        #           withdrawn from screen again and will get delayed like a new notification
        # fullscreen_delay_everything = {
        #   fullscreen = "delay";
        # };

        fullscreen_show_critical = {
          msg_urgency = "critical";
          fullscreen = "show";
        };

        ignore = {
          # This notification will not be displayed
          summary = "foobar";
          skip_display = true;
        };

        history-ignore = {
          # This notification will not be saved in history
          summary = "foobar";
          history_ignore = "yes";
        };

        music = {
          appname = "music";
          set_stack_tag = "music";
          urgency = "low";
          timeout = 10;
        };

        skip-display = {
          # This notification will not be displayed, but will be included in the history
          summary = "foobar";
          skip_display = "yes";
        };

        stack-volumes = {
          appname = "change-volume";
          set_stack_tag = "volume";
          timeout = 2;
          fullscreen = "show";
        };

        stack-brightness = {
          appname = "change-brightness";
          set_stack_tag = "brightness";
          timeout = 2;
          fullscreen = "show";
        };
      };
    };
  };
}
