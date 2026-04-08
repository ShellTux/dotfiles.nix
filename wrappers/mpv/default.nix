{
  config,
  pkgs,
  wlib,
  lib,
  ...
}:
let
  inherit (builtins)
    typeOf
    stringLength
    concatStringsSep
    ;
  inherit (lib) mkOption literalExpression mapAttrsToList;
  inherit (lib.types)
    attrsOf
    bool
    either
    enum
    float
    int
    listOf
    str
    ;

  mpvOption = either str (either int (either bool float));
  mpvOptionDup = either mpvOption (listOf mpvOption);
  mpvOptions = attrsOf mpvOptionDup;
  mpvProfiles = attrsOf mpvOptions;
  mpvBindings = attrsOf str;

  yesNo = value: if value then "yes" else "no";

  renderOption =
    option:
    rec {
      int = toString option;
      float = int;
      bool = yesNo option;
      string = option;
    }
    .${typeOf option};

  renderOptionValue =
    value:
    let
      rendered = renderOption value;
      length = toString (stringLength rendered);
    in
    "%${length}%${rendered}";

  renderOptions = lib.generators.toKeyValue {
    mkKeyValue = lib.generators.mkKeyValueDefault { mkValueString = renderOptionValue; } "=";
    listsAsDuplicateKeys = true;
  };

  renderProfiles = lib.generators.toINI {
    mkKeyValue = lib.generators.mkKeyValueDefault { mkValueString = renderOptionValue; } "=";
    listsAsDuplicateKeys = true;
  };

  renderBindings =
    bindings: concatStringsSep "\n" (mapAttrsToList (name: value: "${name} ${value}") bindings);

in
{
  imports = [ wlib.wrapperModules.mpv ];

  options = {
    flavour = mkOption {
      type = enum [
        "none"
        "config1"
      ];
      default = "config1";
      description = ''
        Which flavour of configuration to pick:
        - `none`: No configuration, allowed to change
        - `config1`: Not allowed to change.
      '';
    };

    config = mkOption {
      description = ''
        Configuration written to
        {file}`$XDG_CONFIG_HOME/mpv/mpv.conf`. See
        {manpage}`mpv(1)`
        for the full list of options.
      '';
      type = mpvOptions;
      default = { };
      example = literalExpression ''
        {
          profile = "gpu-hq";
          force-window = true;
          ytdl-format = "bestvideo+bestaudio";
          cache-default = 4000000;
        }
      '';
    };

    profiles = mkOption {
      type = mpvProfiles;
      default = { };
      example = literalExpression ''
        {
          fast = {
            vo = "vdpau";
          };
          "protocol.dvd" = {
            profile-desc = "profile for dvd:// streams";
            alang = "en";
          };
        }
      '';
    };

    bindings = mkOption {
      type = mpvBindings;
      default = { };
      example = literalExpression ''
        {
          WHEEL_UP = "seek 10";
          WHEEL_DOWN = "seek -10";
          "Alt+0" = "set window-scale 0.5";
        }
      '';
    };
  };

  config = {
    "mpv.conf".content =
      if config.flavour == "none" then
        renderOptions config.config
      else if config.flavour == "config1" then
        renderOptions {
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

          msg-color = true;
          msg-module = true;
        }
      else
        null
        + (
          ''

            # Profiles
          ''
          + (
            if config.flavour == "none" then
              renderProfiles config.profiles
            else if config.flavour == "config1" then
              renderProfiles {
                "extension.gif" = {
                  loop-file = "inf";
                };

                "big-cache" = {
                  cache = "yes";
                  demuxer-max-bytes = "1GiB";
                };

                "network" = {
                  profile-cond = "demuxer_via_network == true";
                  profile-desc = "Profile for content over the network";
                  profile = "big-cache";
                };

                "1080p" = {
                  ytdl-format = "ytdl-format=bestvideo[height<=?1080]+bestaudio/best";
                };

                "720p" = {
                  ytdl-format = "ytdl-format=bestvideo[height<=?720]+bestaudio/best";
                };

                "480p" = {
                  ytdl-format = "ytdl-format=bestvideo[height<=?480]+bestaudio/best";
                };

                "360p" = {
                  ytdl-format = "ytdl-format=bestvideo[height<=?360]+bestaudio/best";
                };
              }
            else
              null
          )
        );

    "mpv.input".content =
      if config.flavour == "none" then
        renderBindings config.bindings
      else if config.flavour == "config1" then
        renderBindings {
          "CTRL+SHIFT+p" = "script-binding console/enable";
          F1 = "script-binding console/enable";
          "CTRL+SHIFT+r" = "cycle_values video-rotate 90 180 270 0";
          "Ctrl+Alt+RIGHT" = "cycle video-rotate 90";
          "Ctrl+Alt+LEFT" = "cycle video-rotate -90";
        }
      else
        null;

    scripts =
      let
        inherit (pkgs) mpvScripts;
      in
      if config.flavour == "none" then
        [ ]
      else if config.flavour == "config1" then
        [
          mpvScripts.mpris
          mpvScripts.mpv-cheatsheet-ng
          mpvScripts.mpv-playlistmanager
          mpvScripts.quality-menu
          mpvScripts.thumbfast
          mpvScripts.uosc
          mpvScripts.videoclip
          mpvScripts.webtorrent-mpv-hook
        ]
      else
        null;
  };
}
