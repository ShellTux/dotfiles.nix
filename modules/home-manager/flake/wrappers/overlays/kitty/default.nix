{ config, self', ... }:
let
  c = config.lib.stylix.colors;
in
{
  nixpkgs.overlays = [
    (final: prev: {
      flake.wrappers.kitty = self'.packages.kitty.wrap (
        { config, ... }:
        {
          constructFiles."kitty-stylix-theme" = {
            content = ''
              # Stylix Theme
              # vim:ft=kitty

              ## name:     ${c.scheme-name}
              ## author:   ${c.scheme-author}

              # base00 - Default Background
              background              #${c.base00}
              selection_foreground    #${c.base00}
              cursor_text_color       #${c.base00}
              active_tab_foreground   #${c.base00}
              tab_bar_background      #${c.base00}
              mark1_foreground        #${c.base00}
              mark2_foreground        #${c.base00}
              mark3_foreground        #${c.base00}
              color0                  #${c.base00}

              # base01 - Lighter Background
              inactive_tab_background #${c.base01}

              # base02 - Selection Background
              selection_background    #${c.base02}

              # base03 - Comments / Inactive Borders
              inactive_border_color   #${c.base03}
              color8                  #${c.base03}

              # base04 - Dark Foreground
              # (Often used for subtle text)

              # base05 - Default Foreground
              foreground              #${c.base05}
              inactive_tab_foreground #${c.base05}
              color7                  #${c.base05}

              # base06 - Light Foreground
              # (Often used for bright white)

              # base07 - Light Background
              color15                 #${c.base07}

              # base08 - Red
              color1                  #${c.base08}
              color9                  #${c.base08}

              # base09 - Orange
              # (Kitty template didn't have a direct slot, usually mapped to brights)

              # base0A - Yellow
              bell_border_color       #${c.base0A}
              color3                  #${c.base0A}
              color11                 #${c.base0A}

              # base0B - Green
              color2                  #${c.base0B}
              color10                 #${c.base0B}

              # base0C - Cyan
              mark3_background        #${c.base0C}
              color6                  #${c.base0C}
              color14                 #${c.base0C}

              # base0D - Blue
              active_border_color     #${c.base0D}
              mark1_background        #${c.base0D}
              color4                  #${c.base0D}
              color12                 #${c.base0D}

              # base0E - Magenta
              active_tab_background   #${c.base0E}
              mark2_background        #${c.base0E}
              color5                  #${c.base0E}
              color13                 #${c.base0E}

              # base0F - Brown / Special
              cursor                  #${c.base0F}
              url_color               #${c.base0F}

              # Window Decor
              wayland_titlebar_color  system
              macos_titlebar_color    system
            '';
            relPath = "stylix.kitty.conf";
          };

          extraConfig = ''
            include ${config.constructFiles."kitty-stylix-theme".path}
          '';
        }
      );
    })
  ];
}
