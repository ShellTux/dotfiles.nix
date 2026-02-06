{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool;

  base16Scheme = colorscheme: "${pkgs.base16-schemes}/share/themes/${colorscheme}.yaml";

  cfg = config.stylix;
in
{
  options.stylix = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    stylix = mkDefault {

      base16Scheme = base16Scheme "catppuccin-mocha";
      polarity = "dark";
      imageScalingMode = "stretch";

      fonts = {
        monospace = {
          package = pkgs.jetbrains-mono;
          name = "JetBrains Mono";
        };
        sansSerif = {
          package = pkgs.nerd-fonts.jetbrains-mono;
          name = "JetBrainsMono Nerd Font Propo";
        };
        serif = {
          package = pkgs.dejavu_fonts;
          name = "DejaVu Serif";
        };
        emoji = {
          package = pkgs.noto-fonts-color-emoji;
          name = "Noto Color Emoji";
        };
      };

      icons = {
        enable = true;
        package = pkgs.catppuccin-papirus-folders.override {
          flavor = "mocha";
          accent = "green";
        };

        dark = "Papirus-Dark";
        light = "Papirus-Light";
      };

      cursor = {
        name = "Bibata-Modern-Classic";
        package = pkgs.bibata-cursors;
        size = 28;
      };

      opacity = {
        popups = 0.9;
        terminal = 0.85;
      };

      targets = {
        kde.enable = false;
        nixvim.enable = false;
      };
    };

    # FIX: https://github.com/nix-community/stylix/issues/412
    xdg.systemDirs.config = [ "/etc/xdg" ];
  };
}
