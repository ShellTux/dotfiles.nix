{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.programs.mpv;
in
{
  config = {
    programs.mpv = mkIf (cfg.enable && !cfg.disableModule) {
      config = {
        # Audio
        volume = 50;
        ao = "pipewire,pulse,alsa";

        # Subtitles
        slang = "por-PT,pt-PT,pt,por,por-BR,pt-BR,eng,en,jpn,ja";
        subs-with-matching-audio = "yes";
        # ISO 639 language codes source:
        # https://www.loc.gov/standards/iso639-2/php/code_list.php
        # https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes

        # Screenshot
        screenshot-template = "%F_%P";
        # screenshot-directory = "~/Imagens/MPV Screenshots";

        osd-font-size = 20;
        sub-font-size = 34;

        msg-color = "yes";
        msg-module = "yes";
      };
    };

    wayland.windowManager.hyprland.settings.windowrule = [
      "idleinhibit, focus, class:mpv"
      "opaque, class:mpv"
    ];
  };
}
