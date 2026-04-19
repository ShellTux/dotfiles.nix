{
  config,
  lib,
  ...
}:
let
  inherit (builtins)
    concatStringsSep
    parseDrvName
    stringLength
    typeOf
    listToAttrs
    ;
  inherit (lib)
    literalExpression
    mapAttrsToList
    mkOption
    pipe
    ;
  inherit (lib.types)
    attrsOf
    bool
    either
    enum
    float
    int
    listOf
    package
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
  imports = [
    ./none
    ./config1
  ];

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

    mpv-scripts = mkOption {
      type = listOf package;
      default = [ ];
      example = literalExpression "[ pkgs.mpvScripts.mpris ]";
      description = ''
        List of scripts to use with mpv.
      '';
    };
  };

  config = {
    "mpv.conf".content = ''
      # Config
      ${renderOptions config.config}

      # Profiles
      ${renderProfiles config.profiles}
    '';

    "mpv.input".content = renderBindings config.bindings;

    script = pipe config.mpv-scripts [
      (
        list:
        map (pkg: {
          # Extract the name (removing potential "mpv-" prefixes if desired)
          name = pkg.pname or (parseDrvName pkg.name).name;
          value = {
            path = pkg;
          };
        }) list
      )
      listToAttrs
    ];
  };
}
