{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (builtins) readFile;
  inherit (lib) mkOption pipe;
  inherit (lib.types) attrs;

  toTOML = path: (pkgs.formats.toml { }).generate path;
in
{
  imports = [
    ./none
    ./config1
  ];

  options = {
    settings = mkOption {
      type = attrs; # Use lib.types.submodule {...} for strict schemas
      default = { };
      description = "Arbitrary configuration to be rendered as TOML.";
      example = {
        pyprland = {
          variables.TERMINAL = "kitty";
          plugins = [
            "magnify"
            "scratchpads"
          ];
        };

        magnify.duration = 25;

        scratchpads.term = {
          animation = "fromTop";
          command = "[TERMINAL]";
          class = "kitty-dropterm";
          margin = 50;
        };
      };
    };
  };

  config = {
    flags = { };
    flagSeparator = "=";

    constructFiles."pypr.toml" = {
      content = pipe config.settings [
        (toTOML "pypr.toml")
        readFile
      ];
      relPath = ".config/pypr.toml";
    };

    package = pkgs.pyprland;
  };
}
