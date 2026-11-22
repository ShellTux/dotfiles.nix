{
  config,
  lib,
  ...
}:
let
  inherit (builtins) elem;
  inherit (lib)
    attrNames
    concatMap
    mkIf
    mkOption
    recursiveUpdate
    types
    ;

  cfg = config.wayland.windowManager.hyprland;

  # Match types whose pattern is a boolean rather than a regex/string.
  boolMatches = [
    "float"
    "focus"
    "fullscreen"
  ];

  normalizePattern =
    matchType: pattern: if elem matchType boolMatches then pattern == "true" else pattern;

  # Project the grouped declaration into the flat array home-manager expects.
  projectRules =
    rules:
    concatMap (
      matchType:
      concatMap (
        pattern:
        map (
          effect: recursiveUpdate { match.${matchType} = normalizePattern matchType pattern; } effect
        ) rules.${matchType}.${pattern}
      ) (attrNames rules.${matchType})
    ) (attrNames rules);
in
{
  options.wayland.windowManager.hyprland.windowRules = mkOption {
    type = types.attrsOf (types.attrsOf (types.listOf (types.attrsOf types.anything)));
    description = ''
      Window rules grouped by match type (class, title, initial_title, ...)
      and pattern. Every pattern maps to a list of effects, which are
      projected into the flat `settings.window_rule` array.
    '';
    default = {
      class = {
        confirm = [ { float = true; } ];
        confirmreset = [ { float = true; } ];
        dialog = [ { float = true; } ];
        download = [ { float = true; } ];
        error = [ { float = true; } ];
        file_progress = [ { float = true; } ];
        file-roller = [ { float = true; } ];
        gcolor3 = [ { float = true; } ];
        Lxappearance = [ { float = true; } ];
        nannou = [ { float = true; } ];
        nm-connection-editor = [ { float = true; } ];
        notification = [ { float = true; } ];
        OpenGL = [ { float = true; } ];
        "org.kde.polkit-kde-authentication-agent-1" = [ { float = true; } ];
        pavucontrol = [ { float = true; } ];
        pavucontrol-qt = [ { float = true; } ];
        qt5ct = [ { float = true; } ];
        Rofi = [ { float = true; } ];
        Scratchpad = [ { float = true; } ];
        splash = [ { float = true; } ];
        syncthing-gtk = [ { float = true; } ];
        syncthingtray = [ { float = true; } ];
        viewnior = [ { float = true; } ];
        Viewnior = [ { float = true; } ];
        xdg-desktop-portal-gtk = [ { float = true; } ];

        "^(Vídeo em janela flutuante|Picture-in-Picture)$" = [
          { opaque = true; }
        ];
        "^wofi$" = [
          { border_size = 0; }
        ];
        mpv = [
          {
            idle_inhibit = "focus";
            opaque = true;
          }
        ];

        "com.stremio.stremio" = [
          { idle_inhibit = "focus"; }
          { workspace = "7"; }
        ];

        "brave-browser" = [
          {
            border_color = {
              colors = [
                "rgba(ffff00ee)"
                "rgba(00ffffee)"
              ];
              angle = 33;
            };
          }
          { idle_inhibit = "focus"; }
          { idle_inhibit = "fullscreen"; }
        ];

        "org.jellyfin.JellyfinDesktop" = [
          { idle_inhibit = "focus"; }
        ];

        "firefox(-developer-edition)?" = [
          { idle_inhibit = "fullscreen"; }
        ];

        wlogout = [
          { fullscreen = true; }
        ];

        "com.github.iwalton3.jellyfin-mpv-shim" = [ { scroll_touchpad = 0.1; } ];

        Alacritty = [ { workspace = "1"; } ];
        "Arduino IDE" = [ { workspace = "1"; } ];
        firefox = [ { workspace = "2"; } ];
        krita = [ { workspace = "4"; } ];
        xournalpp = [ { workspace = "4"; } ];
        "one.alynx.showmethekey" = [ { workspace = "5"; } ];
        "org.keepassxc.KeePassXC" = [ { workspace = "5"; } ];
        "com.obsproject.Studio" = [ { workspace = "7"; } ];
        "Jellyfin Media Player" = [ { workspace = "7"; } ];
        "org.jellyfin.jellyfinmediaplayer" = [ { workspace = "7"; } ];
        com-atlauncher-App = [ { workspace = "8"; } ];
        lutris = [ { workspace = "8"; } ];
        Minecraft = [ { workspace = "8"; } ];
        PPSSPPQt = [ { workspace = "8"; } ];
        PPSSPPSDL = [ { workspace = "8"; } ];
        rpcs3 = [ { workspace = "8"; } ];
        steam = [ { workspace = "8"; } ];
        Steam = [ { workspace = "8"; } ];
        discord = [ { workspace = "9"; } ];
        Slack = [ { workspace = "9"; } ];
        WebCord = [ { workspace = "9"; } ];
        zoom = [ { workspace = "9"; } ];
      };

      title = {
        branchdialog = [ { float = true; } ];
        "Confirm to replace files" = [ { float = true; } ];
        "^/dev/ttyUSB" = [ { float = true; } ];
        "File Operation Progress" = [ { float = true; } ];
        "^(Media viewer)$" = [ { float = true; } ];
        "Open File" = [ { float = true; } ];
        "^(Picture-in-Picture)$" = [ { float = true; } ];
        "^(Vídeo em janela flutuante)$" = [ { float = true; } ];
        "^(Volume Control)$" = [ { float = true; } ];
        wlogout = [
          { float = true; }
          { fullscreen = true; }
        ];
        "^(Floating Window - Show Me The Key)$" = [
          { float = true; }
          { pin = true; }
        ];
        "^Extension:.*- Bitwarden — (Ablaze Floorp|Firefox)$" = [
          {
            float = true;
            no_screen_share = true;
          }
        ];
        "^Bitwarden$" = [
          {
            float = true;
            no_screen_share = true;
          }
        ];
        "(.*)(Youtube)(.*)" = [
          {
            idle_inhibit = "focus";
            opaque = true;
          }
        ];
        "(.*)(YouTube)(.*)" = [
          {
            idle_inhibit = "focus";
            opaque = true;
          }
        ];
        "^(Vídeo em janela flutuante|Picture-in-Picture)$" = [
          { pin = true; }
        ];
        "^(Firefox — Sharing Indicator)$" = [ { workspace = "special:silent"; } ];
        "^(Zen — Sharing Indicator)$" = [ { workspace = "special:silent"; } ];
        "^(.*is sharing (your screen|a window)\\.)$" = [ { workspace = "special:silent"; } ];
      };

      initial_title = {
        "^(Save File)$" = [
          { float = true; }
          {
            size = [
              "<50%"
              "<50%"
            ];
          }
        ];
        "(.*)(wants to save)$" = [
          { float = true; }
          {
            size = [
              "<50%"
              "<50%"
            ];
          }
        ];
        "(Rename:.*)" = [ { float = true; } ];
        "(Renomear:.*)" = [ { float = true; } ];
        "(File Operation Progress.*)" = [ { float = true; } ];
        "(Progresso da operação do ficheiro.*)" = [ { float = true; } ];
      };

      focus = {
        "true" = [
          { center = true; }
        ];
      };

      float = {
        "true" = [
          {
            size = [
              "<60%"
              "<70%"
            ];
          }
        ];
      };
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    wayland.windowManager.hyprland.settings.window_rule = projectRules cfg.windowRules;
  };
}
