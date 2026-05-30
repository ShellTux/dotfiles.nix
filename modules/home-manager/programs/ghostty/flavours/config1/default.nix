{
  config,
  lib,
  inputs,
  ...
}:
let
  inherit (lib)
    mkIf
    mkDefault
    pipe
    range
    ;
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
      cursor-style = mkDefault "block";
      custom-shader = mkDefault "${ghostty-cursor-shaders}/cursor_warp.glsl";
      font-size = mkDefault 12;
      gtk-tabs-location = "bottom";
      gtk-titlebar = false;
      mouse-hide-while-typing = true;
      resize-overlay = "never";
      tab-inherit-working-directory = false;
      term = "xterm-ghostty";
      theme = mkDefault "tokyonight_moon";
      window-decoration = false;
      window-inherit-working-directory = false;

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

        "ctrl+shift+c=copy_to_clipboard"
        "ctrl+shift+v=paste_from_clipboard"

        "alt+left=esc:b"
        "alt+right=esc:f"

        "ctrl+plus=increase_font_size:1"
        "ctrl+kp_subtract=decrease_font_size:1"
        "ctrl+kp_multiply=reset_font_size"
      ]
      ++ pipe (range 1 9) [
        (map toString)
        (map (tab: "${leader-key}>${tab}=goto_tab:${tab}"))
      ];
    };
  };
}
