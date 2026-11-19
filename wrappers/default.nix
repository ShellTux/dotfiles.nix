{ lib, ... }:
let
  inherit (builtins)
    baseNameOf
    head
    isPath
    listToAttrs
    map
    ;
  inherit (lib)
    pipe
    nameValuePair
    types
    mkOption
    ;

  wrapper-module-import =
    opts:
    let
      path = opts.path or opts;
      name = baseNameOf path;

      defaultFlavours = [
        "config1"
        "none"
      ];

      flavour = {
        type = opts.flavour.type or types.enum (
          opts.flavours or [
            "config1"
            "none"
          ]
        );

        default = opts.flavour.default or (head defaultFlavours);
      };
    in
    nameValuePair name (
      { wlib, lib, ... }:
      {
        imports = [
          path
          (if wlib.wrapperModules ? ${name} then wlib.wrapperModules.${name} else wlib.modules.default)
        ];

        options.flavour = mkOption {
          inherit (flavour) type default;
        };
      }
    );
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
        {
          path = ./git;
          flavour.default = "difftastic";
          flavours = [
            "none"
            "delta"
            "diff-so-fancy"
            "difftastic"
            "diffr"
          ];
        }
        ./htop
        ./imv
        ./kitty
        ./mpv
        ./noctalia
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
