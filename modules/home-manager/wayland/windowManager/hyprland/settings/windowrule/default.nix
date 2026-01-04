{ flake-lib, ... }:
let
  inherit (flake-lib.hyprland.windowrule)
    center
    float
    fullscreen
    idleinhibit
    no_anim
    pin
    size
    stay_focused
    workspace
    ;
in
{
  config.wayland.windowManager.hyprland.settings.windowrule = [
    # Floating {{{

    (float { match = "class confirm"; })
    (float { match = "class confirmreset"; })
    (float { match = "class dialog"; })
    (float { match = "class download"; })
    (float { match = "class error"; })
    (float { match = "class file_progress"; })
    (float { match = "class file-roller"; })
    (float { match = "class gcolor3"; })
    (float { match = "class Lxappearance"; })
    (float { match = "class nannou"; })
    (float { match = "class nm-connection-editor"; })
    (float { match = "class notification"; })
    (float { match = "class OpenGL"; })
    (float { match = "class org.kde.polkit-kde-authentication-agent-1"; })
    (float { match = "class pavucontrol"; })
    (float { match = "class pavucontrol-qt"; })
    (float { match = "class qt5ct"; })
    (float { match = "class Rofi"; })
    (float { match = "class Scratchpad"; })
    (float { match = "class splash"; })
    (float { match = "class syncthing-gtk"; })
    (float { match = "class syncthingtray"; })
    (float { match = "title branchdialog"; })
    (float { match = "title Confirm to replace files"; })
    (float { match = "title ^/dev/ttyUSB"; })
    (float { match = "title File Operation Progress"; })
    (float { match = "title ^(Media viewer)$"; })
    (float { match = "title Open File"; })
    (float { match = "title ^(Picture-in-Picture)$"; })
    (float { match = "title ^(Vídeo em janela flutuante)$"; })
    (float { match = "title ^(Volume Control)$"; })
    (float { match = "title wlogout"; })
    (float { match = "class viewnior"; })
    (float { match = "class Viewnior"; })
    (float { match = "class xdg-desktop-portal-gtk"; })

    # }}}

    # Idlle Inhibit {{{

    (idleinhibit {
      idle_inhibit = "focus";
      match = "class com.stremio.stremio";
    })

    # }}}

    (center { match = "float yes"; })
    (size {
      match = "float yes";
      width = "<60%";
      height = "<70%";
    })
    (no_anim { match = "class Rofi"; })
    (fullscreen { match = "title wlogout"; })
    (fullscreen { match = "class wlogout"; })
    (float { match = "title ^(Floating Window - Show Me The Key)$"; })
    (pin { match = "title ^(Floating Window - Show Me The Key)$"; })
    (no_anim { match = "class ^ueberzugpp_.*$"; })

    # Workspace {{{

    (workspace 1 { match = "class Alacritty"; })
    (workspace 1 { match = "class Arduino IDE"; })
    (workspace 2 { match = "class firefox"; })
    (workspace 4 { match = "class krita"; })
    (workspace 4 { match = "class xournalpp"; })
    (workspace 5 { match = "class one.alynx.showmethekey"; })
    (workspace 5 { match = "class org.keepassxc.KeePassXC"; })
    (workspace 7 { match = "class com.obsproject.Studio"; })
    (workspace 7 { match = "class com.stremio.stremio"; })
    (workspace 7 { match = "class Jellyfin Media Player"; })
    (workspace 7 { match = "class org.jellyfin.jellyfinmediaplayer"; })
    (workspace 8 { match = "class com-atlauncher-App"; })
    (workspace 8 { match = "class lutris"; })
    (workspace 8 { match = "class Minecraft"; })
    (workspace 8 { match = "class PPSSPPQt"; })
    (workspace 8 { match = "class PPSSPPSDL"; })
    (workspace 8 { match = "class rpcs3"; })
    (workspace 8 { match = "class steam"; })
    (workspace 8 { match = "class Steam"; })
    (workspace 8 { match = "class SummertimeSaga"; }) # 😉
    (workspace 9 { match = "class discord"; })
    (workspace 9 { match = "class Slack"; })
    (workspace 9 { match = "class WebCord"; })
    (workspace 9 { match = "class zoom"; })

    # }}}

    (stay_focused { match = "class (pinentry-)(.*)"; })
  ];
}
