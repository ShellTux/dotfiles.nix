{
  config,
  lib,
  ...
}:
let
  inherit (builtins)
    concatStringsSep
    filter
    stringLength
    toString
    ;
  inherit (lib) mkIf mkMerge;

  scratchpad =
    {
      key,
      command ? "",
      width ? 80,
      height ? 80,
      style ? "rounded",
    }:
    let
      session-suffix =
        [
          key
          command
        ]
        |> filter (s: stringLength s > 0)
        |> concatStringsSep "-";

      session-name = "scratch-${session-suffix}";
      cmd = if stringLength command == 0 then "" else "'${command}'";
    in
    ''
        bind-key -n ${key} if-shell -F '#{==:#{session_name},${session-name}}' {
          detach-client
      } {
          display-popup -w ${toString width}% -h ${toString height}% -s ${style} -T "#[fg=white]${command} <${key}>" -E "tmux new-session -A -s '${session-name}' ${cmd}"
      }
    '';

  cfg = config.programs.tmux;
in
{
  config = mkIf (cfg.enable && !cfg.disableModule) {
    programs.tmux.extraConfig = mkMerge [
      "set-option -g prefix2 C-b"
      "bind -r h select-pane -L"
      "bind -r j select-pane -D"
      "bind -r k select-pane -U"
      "bind -r l select-pane -R"
      "bind -r H resize-pane -L 5"
      "bind -r J resize-pane -D 5"
      "bind -r K resize-pane -U 5"
      "bind -r L resize-pane -R 5"
      "bind -r M-h resize-pane -L 1"
      "bind -r M-j resize-pane -D 1"
      "bind -r M-k resize-pane -U 1"
      "bind -r M-l resize-pane -R 1"
      ""
      "# urxvt tab like window switching (-n: no prior escape seq)"
      "bind -n S-down new-window"
      "bind -n S-left prev"
      "bind -n S-right next"
      "bind -n C-left swap-window -t -1"
      "bind -n C-right swap-window -t +1"
      ""
      "# Open new panes in current directory"
      ''# bind c new-window -c "#{pane_current_path}"''
      ''bind '"' split-window -c "#{pane_current_path}"''
      ''bind % split-window -h -c "#{pane_current_path}"''
      ''bind | split-window -h -c "#{pane_current_path}"''
      ''bind - split-window -v -c "#{pane_current_path}"''
      ""
      "# Clear Screen because Control+l is taken by vim-tmux-navigator"
      ''bind-key C-l send-keys "C-l"''
      ""
      (scratchpad { key = "M-s"; })
      (scratchpad {
        key = "M-x";
        command = "qalc";
      })
      (scratchpad {
        key = "M-m";
        command = "rmpc";
      })
    ];
  };
}
