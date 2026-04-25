{ ... }:
let
  wrapper-module-import =
    path:
    {
      self',
      lib,
      pkgs,
      ...
    }:
    let
      inherit (lib) mkEnableOption mkOption;
      inherit (lib.types) package;

      name = baseNameOf path;
    in
    {
      imports = [ path ];

      options.flake.wrappers.${name} = {
        enable = mkEnableOption name;

        package = mkOption {
          type = package;
          default = pkgs.flake.wrappers.${name} or self'.packages.${name};
          example = pkgs.${name};
          description = "The ${name} package to use.";
        };
      };
    };
in
{
  imports =
    map wrapper-module-import [
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
      ./vim
      ./yazi
      ./yt-dlp
    ]
    ++ [ ./overlays ];

}
