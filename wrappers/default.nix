{ lib, ... }:
let
  inherit (builtins) baseNameOf listToAttrs map;
  inherit (lib) pipe;
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
        (map (path: rec {
          name = baseNameOf path;
          value.imports = [
            path
            (
              { wlib, ... }:
              {
                imports = [
                  (if wlib.wrapperModules ? ${name} then wlib.wrapperModules.${name} else wlib.modules.default)
                ];
              }
            )
          ];
        }))
        listToAttrs
      ];
}
