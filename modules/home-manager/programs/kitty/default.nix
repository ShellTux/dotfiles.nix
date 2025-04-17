{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool;

  tmux-prefix = "ctrl+space";
  tmux-keybindings = {
    "${tmux-prefix}>c" = "new_tab";
    "${tmux-prefix}>n" = "next_tab";
    "${tmux-prefix}>p" = "previous_tab";
    "${tmux-prefix}>," = "set_tab_title";
    "shift+down" = "new_tab";
    "shift+left" = "previous_tab";
    "shift+right" = "next_tab";

    "${tmux-prefix}>|" = "launch --location=vsplit --cwd=current";
    "${tmux-prefix}>%" = "launch --location=vsplit --cwd=current";
    "${tmux-prefix}>-" = "launch --location=hsplit --cwd=current";

    "${tmux-prefix}>h" = "neighboring_window left";
    "${tmux-prefix}>j" = "neighboring_window down";
    "${tmux-prefix}>k" = "neighboring_window up";
    "${tmux-prefix}>l" = "neighboring_window right";
    "ctrl+h" = "neighboring_window left";
    "ctrl+j" = "neighboring_window down";
    "ctrl+k" = "neighboring_window up";
    "ctrl+l" = "neighboring_window right";
    "ctrl+left" = "move_tab_backward";
    "ctrl+right" = "move_tab_forward";

    "${tmux-prefix}>alt+h" = "resize_window narrower";
    "${tmux-prefix}>alt+l" = "resize_window wider";
    "${tmux-prefix}>alt+j" = "resize_window shorter";
    "${tmux-prefix}>alt+k" = "resize_window taller";
    "${tmux-prefix}>shift+h" = "resize_window narrower 3";
    "${tmux-prefix}>shift+l" = "resize_window wider 3";
    "${tmux-prefix}>shift+j" = "resize_window shorter 3";
    "${tmux-prefix}>shift+k" = "resize_window taller 3";
    "${tmux-prefix}>=" = "resize_window reset";

    "${tmux-prefix}>z" = "combine : toggle_layout stack : scroll_prompt_to_bottom";
    "${tmux-prefix}>[" = "show_scrollback";
    "${tmux-prefix}>]" = "paste_from_clipboard";
  };

  cfg = config.programs.kitty;
in
{
  options.programs.kitty = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    programs.kitty = {
      font = mkDefault {
        # TODO: make sure to install fonts
        name = "JetBrains Mono";
        size = 12;
      };

      settings = {
        background_opacity = mkDefault "0.8";
        cursor_shape = "block";
        cursor_text_color = "background";
        cursor_trail = 50;
        dim_opacity = "0.75";
        disable_ligatures = "cursor";
        enabled_layouts = "splits:split_axis=horizontal,stack,tall";
        selection_background = "#fffacd";
        selection_foreground = "#000000";
        scrollback_pager = ''
          vim -u NONE -
            \ -c 'w! /tmp/kitty_scrollback'
            \ -c 'term ++curwin cat /tmp/kitty_scrollback'
            \ -c "set clipboard=unnamed"
            \ -c "hi Normal ctermbg=235"
            \ -c "nnoremap Y y$"
            \ -c "tnoremap i ZQ"'';
        shell_integration = "no-cursor";
        update_check_interval = 0;
        # Nerd Fonts Version: 3.2.1
        symbol_map = "U+e000-U+e00a,U+e0a0-U+e0a2,U+e0b0-U+e0b3,U+e0a3-U+e0a3,U+e0b4-U+e0c8,U+e0cc-U+e0d2,U+e0d4-U+e0d4,U+e0d6-U+e0d7,U+e5fa-U+e6b2,U+e700-U+e7c5,U+f000-U+f2e0,U+e200-U+e2a9,U+f400-U+f4a8,U+2665-U+2665,U+26A1-U+26A1,U+f27c-U+f27c,U+f300-U+f372,U+23fb-U+23fe,U+2b58-U+2b58,U+f0001-U+f0010,U+e300-U+e3eb Symbols Nerd Font";
      };

      keybindings = tmux-keybindings;
    };
  };
}
