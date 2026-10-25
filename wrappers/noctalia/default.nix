{
  wlib,
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (builtins) readFile;
  inherit (lib) mkOption pipe;
  inherit (lib.types) attrs path;

  toTOML = path: (pkgs.formats.toml { }).generate path;
in
{
  imports = [
    ./none
    ./config1
  ];

  options = {
    configDir = mkOption {
      type = path;
      description = "Directory containing the Noctalia profile";
    };

    settings = mkOption {
      type = attrs; # Use lib.types.submodule {...} for strict schemas
      default = { };
      description = "Arbitrary configuration to be rendered as TOML.";
      example = { };
    };
  };

  config = {
    package = pkgs.noctalia;
    flags = { };
    flagSeparator = "=";
    env = {
      NOCTALIA_CONFIG_HOME = config.constructFiles."settings.toml".path;
    };

    constructFiles."settings.toml" = {
      content = pipe config.settings [
        (toTOML "settings.toml")
        readFile
      ];
      relPath = ".config/noctalia/settings.toml";
    };

  };
}
