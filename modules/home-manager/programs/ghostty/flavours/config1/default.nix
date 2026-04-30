{
  config,
  lib,
  inputs,
  ...
}:
let
  inherit (lib) mkIf mkDefault;
  inherit (cfg) leader-key;
  inherit (inputs) ghostty-cursor-shaders;

  cfg = config.programs.ghostty;
in
mkIf (cfg.enable && cfg.flavour == "config1") {
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
      custom-shader = mkDefault "${ghostty-cursor-shaders}/cursor_warp.glsl";

      keybind = [
        "ctrl+page_up=unbind"
        "ctrl+page_down=unbind"
        "ctrl+shift+page_up=unbind"
        "ctrl+shift+page_down=unbind"

        "${leader-key}>c=new_tab"
        "shift+down=new_tab"
        "shift+left=previous_tab"
        "shift+right=next_tab"

        "${leader-key}>h=goto_split:left"
        "${leader-key}>j=goto_split:bottom"
        "${leader-key}>k=goto_split:top"
        "${leader-key}>l=goto_split:right"
        "ctrl+h=goto_split:left"
        "ctrl+j=goto_split:bottom"
        "ctrl+k=goto_split:top"
        "ctrl+l=goto_split:right"
        "${leader-key}>shift+h=resize_split:left,30"
        "${leader-key}>shift+j=resize_split:down,30"
        "${leader-key}>shift+k=resize_split:up,30"
        "${leader-key}>shift+l=resize_split:right,30"
        "${leader-key}>alt+h=resize_split:left,30"
        "${leader-key}>alt+j=resize_split:down,30"
        "${leader-key}>alt+k=resize_split:up,30"
        "${leader-key}>alt+l=resize_split:right,30"
        # "${leader-key}>\==equalize_splits"

        "${leader-key}>shift+\\=new_split:right"
        "${leader-key}>shift+5=new_split:right"
        "${leader-key}>-=new_split:down"
        "${leader-key}>z=toggle_split_zoom"

        "ctrl+shift+u=unbind"
      ];
    };
  };
}
