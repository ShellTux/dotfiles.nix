{ lib, ... }:
let
  inherit (builtins) baseNameOf listToAttrs map;
  inherit (lib) pipe;

  wrapper-module-import = path: rec {
    name = baseNameOf path;
    value =
      { wlib, lib, ... }:
      let
        inherit (lib) mkOption;
        inherit (lib.types) enum;
      in
      {
        imports = [
          path
          (if wlib.wrapperModules ? ${name} then wlib.wrapperModules.${name} else wlib.modules.default)
        ];

        options.flavour = mkOption {
          type = enum [
            "none"
            "config1"
          ];
          default = "config1";
        };
      };
  };
in
{
  flake.wrappers =
    pipe
      [
        ./bat
        ./btop
        ./eza
        ./fastfetch
        ./fd
        ./git
        ./htop
        ./imv
        ./kitty
        ./mpv
        ./noctalia-shell
        ./rofi
        ./vim
        ./waybar
        ./yazi
        ./yt-dlp
        ./zathura
        # ./zsh
      ]
      [
        (map wrapper-module-import)
        listToAttrs
      ];
}
