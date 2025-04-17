{ config, lib, ... }:
let
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool;

  tmux-prefix = "ctrl+space";

  cfg = config.programs.ghostty;
in
{
  options.programs.ghostty = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    programs.ghostty = {
      clearDefaultKeybinds = true;
      installBatSyntax = true;
      installVimSyntax = true;

      settings = {
        auto-update = "off";
        cursor-style = "bar";
        font-size = mkDefault 12;
        gtk-titlebar = false;
        mouse-hide-while-typing = true;
        resize-overlay = "never";
        term = "xterm-ghostty";
        theme = mkDefault "tokyonight_moon";
        window-decoration = false;

        keybind = [
          "ctrl+page_up=unbind"
          "ctrl+page_down=unbind"
          "ctrl+shift+page_up=unbind"
          "ctrl+shift+page_down=unbind"

          "${tmux-prefix}>c=new_tab"
          "shift+down=new_tab"
          "shift+left=previous_tab"
          "shift+right=next_tab"

          "${tmux-prefix}>h=goto_split:left"
          "${tmux-prefix}>j=goto_split:bottom"
          "${tmux-prefix}>k=goto_split:top"
          "${tmux-prefix}>l=goto_split:right"
          "ctrl+h=goto_split:left"
          "ctrl+j=goto_split:bottom"
          "ctrl+k=goto_split:top"
          "ctrl+l=goto_split:right"
          "${tmux-prefix}>shift+h=resize_split:left,30"
          "${tmux-prefix}>shift+j=resize_split:down,30"
          "${tmux-prefix}>shift+k=resize_split:up,30"
          "${tmux-prefix}>shift+l=resize_split:right,30"
          "${tmux-prefix}>alt+h=resize_split:left,30"
          "${tmux-prefix}>alt+j=resize_split:down,30"
          "${tmux-prefix}>alt+k=resize_split:up,30"
          "${tmux-prefix}>alt+l=resize_split:right,30"
          # "${tmux-prefix}>\==equalize_splits"

          "${tmux-prefix}>shift+\\=new_split:right"
          "${tmux-prefix}>shift+5=new_split:right"
          "${tmux-prefix}>-=new_split:down"
          "${tmux-prefix}>z=toggle_split_zoom"

          "ctrl+shift+u=unbind"
        ];
      };

    };
  };
}
