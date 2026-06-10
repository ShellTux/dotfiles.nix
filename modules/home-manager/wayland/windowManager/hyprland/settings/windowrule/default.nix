{ lib', ... }:
let
  inherit (lib'.flake.hyprland.lua)
    mkWindowRule
    mkWindowRuleCenter
    mkWindowRuleFloat
    mkWindowRuleFullscreen
    mkWindowRuleIdleInhibit
    mkWindowRulePin
    mkWindowRuleWorkspace
    ;

in
{
  config.wayland.windowManager.hyprland.settings.window_rule =
    map mkWindowRuleFloat [
      { match.class = "confirm"; }
      { match.class = "confirmreset"; }
      { match.class = "dialog"; }
      { match.class = "download"; }
      { match.class = "error"; }
      { match.class = "file_progress"; }
      { match.class = "file-roller"; }
      { match.class = "gcolor3"; }
      { match.class = "Lxappearance"; }
      { match.class = "nannou"; }
      { match.class = "nm-connection-editor"; }
      { match.class = "notification"; }
      { match.class = "OpenGL"; }
      { match.class = "org.kde.polkit-kde-authentication-agent-1"; }
      { match.class = "pavucontrol"; }
      { match.class = "pavucontrol-qt"; }
      { match.class = "qt5ct"; }
      { match.class = "Rofi"; }
      { match.class = "Scratchpad"; }
      { match.class = "splash"; }
      { match.class = "syncthing-gtk"; }
      { match.class = "syncthingtray"; }
      { match.title = "branchdialog"; }
      { match.title = "Confirm to replace files"; }
      { match.title = "^/dev/ttyUSB"; }
      { match.title = "File Operation Progress"; }
      { match.title = "^(Media viewer)$"; }
      { match.title = "Open File"; }
      { match.title = "^(Picture-in-Picture)$"; }
      { match.title = "^(Vídeo em janela flutuante)$"; }
      { match.title = "^(Volume Control)$"; }
      { match.title = "wlogout"; }
      { match.class = "viewnior"; }
      { match.class = "Viewnior"; }
      { match.class = "xdg-desktop-portal-gtk"; }
    ]
    ++ map (mkWindowRuleIdleInhibit "focus") [
      { match.class = "com.stremio.stremio"; }
    ]
    ++ map mkWindowRuleCenter [
      { match.focus = true; }
    ]
    ++ map mkWindowRuleFullscreen [
      { match.title = "wlogout"; }
      { match.class = "wlogout"; }
    ]
    ++ map mkWindowRuleFloat [
      { match.title = "^(Floating Window - Show Me The Key)$"; }
    ]
    ++ map mkWindowRulePin [
      { match.title = "^(Floating Window - Show Me The Key)$"; }
    ]
    ++ map mkWindowRule [
      {
        match.float = true;
        size = [
          "<60%"
          "<70%"
        ];
      }
    ]
    ++ map (mkWindowRuleWorkspace 1) [
      { match.class = "Alacritty"; }
      { match.class = "Arduino IDE"; }
    ]
    ++ map (mkWindowRuleWorkspace 2) [
      { match.class = "firefox"; }
    ]
    ++ map (mkWindowRuleWorkspace 3) [
    ]
    ++ map (mkWindowRuleWorkspace 4) [
      { match.class = "krita"; }
      { match.class = "xournalpp"; }
    ]
    ++ map (mkWindowRuleWorkspace 5) [
      { match.class = "one.alynx.showmethekey"; }
      { match.class = "org.keepassxc.KeePassXC"; }
    ]
    ++ map (mkWindowRuleWorkspace 6) [
    ]
    ++ map (mkWindowRuleWorkspace 7) [
      { match.class = "com.obsproject.Studio"; }
      { match.class = "com.stremio.stremio"; }
      { match.class = "Jellyfin Media Player"; }
      { match.class = "org.jellyfin.jellyfinmediaplayer"; }
    ]
    ++ map (mkWindowRuleWorkspace 8) [
      { match.class = "com-atlauncher-App"; }
      { match.class = "lutris"; }
      { match.class = "Minecraft"; }
      { match.class = "PPSSPPQt"; }
      { match.class = "PPSSPPSDL"; }
      { match.class = "rpcs3"; }
      { match.class = "steam"; }
      { match.class = "Steam"; }
    ]
    ++ map (mkWindowRuleWorkspace 9) [
      { match.class = "discord"; }
      { match.class = "Slack"; }
      { match.class = "WebCord"; }
      { match.class = "zoom"; }
    ]
    ++ [
      # (no_anim { match.class = "Rofi"; })
      # (no_anim { match.class = "^ueberzugpp_.*$"; })

      # (stay_focused { match = "class (pinentry-)(.*)"; })
    ];
}
